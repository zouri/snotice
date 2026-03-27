#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdlib>
#include <string>
#include <vector>

#include "desktop_multi_window/desktop_multi_window_plugin.h"
#include "flutter/generated_plugin_registrant.h"

namespace {

constexpr double kPi = 3.14159265358979323846;

enum NativeOverlayMode {
  kOverlayNone = 0,
  kOverlayFull = 1,
  kOverlayEdge = 2,
  kOverlayBarrage = 3,
};

enum BarrageLane {
  kLaneTop = 0,
  kLaneMiddle = 1,
  kLaneBottom = 2,
};

struct BarrageItem {
  std::string text;
  GdkRGBA text_color{};
  double row_top = 0.0;
  double start_x = 0.0;
  double end_x = 0.0;
  double initial_progress = 0.0;
  double speed_factor = 1.0;
  gint64 start_us = 0;
  int duration_ms = 6000;
  int text_width = 80;
  int text_height = 24;
  int bubble_padding_x = 14;
  int bubble_padding_y = 8;
  int bubble_radius = 12;
  double font_size = 28.0;
};

struct OverlayWindowState {
  GtkWidget* window = nullptr;
  GtkWidget* area = nullptr;
  GdkRectangle bounds{};
  std::vector<BarrageItem> barrage_items;
};

double clamp_double(double value, double min, double max) {
  return std::max(min, std::min(max, value));
}

int clamp_int(int value, int min, int max) {
  return std::max(min, std::min(max, value));
}

double random_between(double min, double max) {
  return min + g_random_double() * (max - min);
}

double middle_signed_step(int index) {
  if (index == 0) {
    return 0.0;
  }
  const double level = static_cast<double>((index + 1) / 2);
  return index % 2 == 1 ? level : -level;
}

double lane_factor(BarrageLane lane) {
  switch (lane) {
    case kLaneMiddle:
      return 0.5;
    case kLaneBottom:
      return 0.82;
    case kLaneTop:
    default:
      return 0.18;
  }
}

BarrageLane parse_barrage_lane(const std::string& lane) {
  if (lane == "middle") {
    return kLaneMiddle;
  }
  if (lane == "bottom") {
    return kLaneBottom;
  }
  return kLaneTop;
}

bool is_edge_effect(const std::string& effect) {
  return effect == "edge" || effect == "edge_sweep" || effect == "sweep" ||
         effect == "edge_pulse" || effect == "pulse" ||
         effect == "edge_dual" || effect == "dual" ||
         effect == "edge_dash" || effect == "dash" ||
         effect == "edge_corner" || effect == "corner" ||
         effect == "edge_rainbow" || effect == "rainbow";
}

std::string to_lower(std::string value) {
  std::transform(value.begin(), value.end(), value.begin(), [](unsigned char c) {
    return static_cast<char>(std::tolower(c));
  });
  return value;
}

std::string trim(std::string value) {
  const auto is_space = [](unsigned char c) {
    return std::isspace(c) != 0;
  };
  value.erase(value.begin(),
              std::find_if(value.begin(), value.end(), [&](unsigned char c) {
                return !is_space(c);
              }));
  value.erase(
      std::find_if(value.rbegin(), value.rend(), [&](unsigned char c) {
        return !is_space(c);
      }).base(),
      value.end());
  return value;
}

FlValue* lookup_map_string(FlValue* map, const char* key) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return nullptr;
  }
  return fl_value_lookup_string(map, key);
}

std::string parse_string_arg(FlValue* map,
                             const char* key,
                             const std::string& fallback) {
  FlValue* value = lookup_map_string(map, key);
  if (value == nullptr) {
    return fallback;
  }
  switch (fl_value_get_type(value)) {
    case FL_VALUE_TYPE_STRING:
      return fl_value_get_string(value);
    case FL_VALUE_TYPE_INT:
      return std::to_string(fl_value_get_int(value));
    case FL_VALUE_TYPE_FLOAT:
      return std::to_string(fl_value_get_float(value));
    default:
      return fallback;
  }
}

int parse_int_arg(FlValue* map, const char* key, int fallback) {
  FlValue* value = lookup_map_string(map, key);
  if (value == nullptr) {
    return fallback;
  }
  switch (fl_value_get_type(value)) {
    case FL_VALUE_TYPE_INT:
      return static_cast<int>(fl_value_get_int(value));
    case FL_VALUE_TYPE_FLOAT:
      return static_cast<int>(std::round(fl_value_get_float(value)));
    case FL_VALUE_TYPE_STRING: {
      const char* raw = fl_value_get_string(value);
      if (raw == nullptr) {
        return fallback;
      }
      char* end = nullptr;
      const long parsed = std::strtol(raw, &end, 10);
      if (end == raw) {
        return fallback;
      }
      return static_cast<int>(parsed);
    }
    default:
      return fallback;
  }
}

double parse_double_arg(FlValue* map, const char* key, double fallback) {
  FlValue* value = lookup_map_string(map, key);
  if (value == nullptr) {
    return fallback;
  }
  switch (fl_value_get_type(value)) {
    case FL_VALUE_TYPE_FLOAT:
      return fl_value_get_float(value);
    case FL_VALUE_TYPE_INT:
      return static_cast<double>(fl_value_get_int(value));
    case FL_VALUE_TYPE_STRING: {
      const char* raw = fl_value_get_string(value);
      if (raw == nullptr) {
        return fallback;
      }
      char* end = nullptr;
      const double parsed = std::strtod(raw, &end);
      if (end == raw) {
        return fallback;
      }
      return parsed;
    }
    default:
      return fallback;
  }
}

GdkRGBA parse_color_arg(FlValue* map, const char* key, const char* fallback) {
  GdkRGBA color{};
  const std::string raw = parse_string_arg(map, key, fallback);
  if (!gdk_rgba_parse(&color, raw.c_str())) {
    gdk_rgba_parse(&color, fallback);
  }
  return color;
}

void draw_rounded_rect(cairo_t* cr,
                       double x,
                       double y,
                       double width,
                       double height,
                       double radius) {
  if (cr == nullptr) {
    return;
  }
  const double r = clamp_double(radius, 0.0, std::min(width, height) * 0.5);
  const double right = x + width;
  const double bottom = y + height;

  cairo_new_sub_path(cr);
  cairo_arc(cr, right - r, y + r, r, -kPi / 2.0, 0);
  cairo_arc(cr, right - r, bottom - r, r, 0, kPi / 2.0);
  cairo_arc(cr, x + r, bottom - r, r, kPi / 2.0, kPi);
  cairo_arc(cr, x + r, y + r, r, kPi, kPi * 1.5);
  cairo_close_path(cr);
}

}  // namespace

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;

  FlMethodChannel* flash_channel;
  std::vector<OverlayWindowState*>* overlay_windows;
  guint animation_timer_id;

  gint overlay_mode;
  gint64 overlay_start_us;
  gint overlay_total_duration_ms;
  gint edge_cycle_duration_ms;
  gdouble edge_line_width;
  gdouble edge_min_alpha;
  gdouble edge_max_alpha;
  GdkRGBA overlay_color;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static gboolean overlay_tick_cb(gpointer user_data);
static gboolean overlay_draw_cb(GtkWidget* widget, cairo_t* cr, gpointer user_data);

static void stop_animation_timer(MyApplication* self) {
  if (self->animation_timer_id != 0) {
    g_source_remove(self->animation_timer_id);
    self->animation_timer_id = 0;
  }
}

static void clear_overlay_windows(MyApplication* self) {
  stop_animation_timer(self);
  self->overlay_mode = kOverlayNone;
  self->overlay_start_us = 0;
  self->overlay_total_duration_ms = 0;

  if (self->overlay_windows == nullptr) {
    return;
  }

  for (auto* overlay : *self->overlay_windows) {
    if (overlay != nullptr && overlay->window != nullptr) {
      gtk_widget_destroy(overlay->window);
      overlay->window = nullptr;
      overlay->area = nullptr;
    }
    delete overlay;
  }
  self->overlay_windows->clear();
}

static void queue_overlay_redraw(MyApplication* self) {
  if (self->overlay_windows == nullptr) {
    return;
  }
  for (auto* overlay : *self->overlay_windows) {
    if (overlay != nullptr && overlay->area != nullptr) {
      gtk_widget_queue_draw(overlay->area);
    }
  }
}

static void start_animation_timer(MyApplication* self, guint interval_ms) {
  stop_animation_timer(self);
  self->animation_timer_id =
      g_timeout_add(interval_ms, overlay_tick_cb, self);
}

static std::vector<GdkRectangle> current_monitor_bounds() {
  std::vector<GdkRectangle> bounds_list;
  GdkDisplay* display = gdk_display_get_default();
  if (display != nullptr) {
    const int monitor_count = gdk_display_get_n_monitors(display);
    for (int index = 0; index < monitor_count; ++index) {
      GdkMonitor* monitor = gdk_display_get_monitor(display, index);
      if (monitor == nullptr) {
        continue;
      }
      GdkRectangle rect{};
      gdk_monitor_get_geometry(monitor, &rect);
      if (rect.width > 0 && rect.height > 0) {
        bounds_list.push_back(rect);
      }
    }
  }

  if (!bounds_list.empty()) {
    return bounds_list;
  }

  GdkScreen* screen = gdk_screen_get_default();
  if (screen != nullptr) {
    GdkRectangle fallback{};
    fallback.x = 0;
    fallback.y = 0;
    fallback.width = gdk_screen_get_width(screen);
    fallback.height = gdk_screen_get_height(screen);
    if (fallback.width > 0 && fallback.height > 0) {
      bounds_list.push_back(fallback);
    }
  }
  return bounds_list;
}

static OverlayWindowState* create_overlay_window(MyApplication* self,
                                                 const GdkRectangle& bounds) {
  auto* overlay = new OverlayWindowState();
  overlay->bounds = bounds;

  overlay->window = gtk_window_new(GTK_WINDOW_POPUP);
  gtk_window_set_application(GTK_WINDOW(overlay->window), GTK_APPLICATION(self));
  gtk_window_set_decorated(GTK_WINDOW(overlay->window), FALSE);
  gtk_window_set_resizable(GTK_WINDOW(overlay->window), FALSE);
  gtk_window_set_skip_taskbar_hint(GTK_WINDOW(overlay->window), TRUE);
  gtk_window_set_skip_pager_hint(GTK_WINDOW(overlay->window), TRUE);
  gtk_window_set_keep_above(GTK_WINDOW(overlay->window), TRUE);
  gtk_window_set_accept_focus(GTK_WINDOW(overlay->window), FALSE);
  gtk_window_stick(GTK_WINDOW(overlay->window));
  gtk_widget_set_app_paintable(overlay->window, TRUE);

  GdkScreen* screen = gtk_widget_get_screen(overlay->window);
  if (screen != nullptr && gdk_screen_is_composited(screen)) {
    GdkVisual* visual = gdk_screen_get_rgba_visual(screen);
    if (visual != nullptr) {
      gtk_widget_set_visual(overlay->window, visual);
    }
  }

  gtk_window_move(GTK_WINDOW(overlay->window), bounds.x, bounds.y);
  gtk_window_set_default_size(GTK_WINDOW(overlay->window), bounds.width,
                              bounds.height);

  overlay->area = gtk_drawing_area_new();
  gtk_widget_set_app_paintable(overlay->area, TRUE);
  gtk_container_add(GTK_CONTAINER(overlay->window), overlay->area);
  g_object_set_data(G_OBJECT(overlay->area), "snotice_app", self);

  g_signal_connect(overlay->area, "draw", G_CALLBACK(overlay_draw_cb), overlay);

  gtk_widget_show_all(overlay->window);
  return overlay;
}

static bool ensure_overlay_windows(MyApplication* self) {
  if (self->overlay_windows == nullptr) {
    return false;
  }
  if (!self->overlay_windows->empty()) {
    return true;
  }

  const auto bounds_list = current_monitor_bounds();
  for (const auto& bounds : bounds_list) {
    self->overlay_windows->push_back(create_overlay_window(self, bounds));
  }
  return !self->overlay_windows->empty();
}

static void append_barrage_items(OverlayWindowState* overlay,
                                 const std::string& text,
                                 const GdkRGBA& color,
                                 int duration_ms,
                                 double speed,
                                 double font_size,
                                 BarrageLane lane,
                                 int repeat_count) {
  if (overlay == nullptr || overlay->bounds.width <= 0 ||
      overlay->bounds.height <= 0) {
    return;
  }

  cairo_surface_t* surface =
      cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 1, 1);
  cairo_t* cr = cairo_create(surface);
  cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL,
                         CAIRO_FONT_WEIGHT_BOLD);
  cairo_set_font_size(cr, font_size);
  cairo_text_extents_t extents{};
  cairo_text_extents(cr, text.c_str(), &extents);
  cairo_destroy(cr);
  cairo_surface_destroy(surface);

  const int text_width =
      std::max(40, static_cast<int>(std::ceil(extents.width + 2.0)));
  const int text_height =
      std::max(20, static_cast<int>(std::ceil(font_size * 1.2)));

  const double width = overlay->bounds.width;
  const double height = overlay->bounds.height;
  const double lane_y = height * lane_factor(lane);
  const double row_spacing =
      std::max(36.0, std::min(120.0, static_cast<double>(text_height) + 12.0));
  const auto clamp_top = [&](double top) {
    const double max_top = std::max(0.0, height - text_height);
    return clamp_double(top, 0.0, max_top);
  };

  const gint64 now_us = g_get_monotonic_time();
  overlay->barrage_items.reserve(overlay->barrage_items.size() + repeat_count);
  for (int index = 0; index < repeat_count; ++index) {
    const double raw_top = [&]() {
      if (lane == kLaneBottom) {
        return lane_y - index * row_spacing;
      }
      if (lane == kLaneMiddle) {
        return lane_y + middle_signed_step(index) * row_spacing;
      }
      return lane_y + index * row_spacing;
    }();

    const double jitter = random_between(-row_spacing * 0.35, row_spacing * 0.35);
    const double spawn_offset = random_between(-width * 0.18, width * 0.35);
    const double end_extra = random_between(0.0, width * 0.2);
    const double initial_progress = random_between(0.06, 0.42);
    const double speed_factor = random_between(0.82, 1.2);

    const double start_x = width + 40.0 + spawn_offset;
    const double end_x = -static_cast<double>(text_width) - 60.0 - end_extra;
    const double adjusted_speed =
        std::max(1.0, speed) * speed_factor * 0.82;
    const double start_x_now =
        start_x + (end_x - start_x) * initial_progress;
    const double remaining_distance = std::max(1.0, start_x_now - end_x);
    const double remaining_travel_seconds =
        remaining_distance / adjusted_speed;
    const double requested_seconds = std::max(0.6, duration_ms / 1000.0);
    const double animation_seconds = std::max(
        requested_seconds * (1.0 - initial_progress * 0.55),
        remaining_travel_seconds);

    BarrageItem item{};
    item.text = text;
    item.text_color = color;
    item.row_top = clamp_top(raw_top + jitter);
    item.start_x = start_x;
    item.end_x = end_x;
    item.initial_progress = initial_progress;
    item.speed_factor = speed_factor;
    item.start_us = now_us;
    item.duration_ms =
        std::max(1, static_cast<int>(std::round(animation_seconds * 1000.0)));
    item.text_width = text_width;
    item.text_height = text_height;
    item.font_size = font_size;
    overlay->barrage_items.push_back(item);
  }
}

static void draw_barrage_items(cairo_t* cr,
                               OverlayWindowState* overlay,
                               gint64 now_us) {
  if (overlay == nullptr) {
    return;
  }
  cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
  cairo_set_line_width(cr, 1.0);

  for (const auto& item : overlay->barrage_items) {
    const double progress = item.duration_ms <= 0
                                ? 1.0
                                : clamp_double(
                                      static_cast<double>(now_us - item.start_us) /
                                          (item.duration_ms * 1000.0),
                                      0.0, 1.0);
    const double base_progress =
        item.initial_progress + (1.0 - item.initial_progress) * progress;
    const double eased_progress =
        1.0 - std::pow(1.0 - base_progress, item.speed_factor);

    const double x = item.start_x + (item.end_x - item.start_x) * eased_progress;
    const double y = item.row_top;

    const double bubble_left = x - item.bubble_padding_x;
    const double bubble_top = y - item.bubble_padding_y;
    const double bubble_width = item.text_width + item.bubble_padding_x * 2.0;
    const double bubble_height = item.text_height + item.bubble_padding_y * 2.0;

    draw_rounded_rect(cr, bubble_left, bubble_top, bubble_width, bubble_height,
                      item.bubble_radius);
    cairo_set_source_rgba(cr, 0.0, 0.0, 0.0, 0.22);
    cairo_fill_preserve(cr);
    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 0.2);
    cairo_stroke(cr);

    cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL,
                           CAIRO_FONT_WEIGHT_BOLD);
    cairo_set_font_size(cr, item.font_size);

    cairo_move_to(cr, x + 1.0, y + item.text_height - 4.0 + 1.0);
    cairo_set_source_rgba(cr, 0.0, 0.0, 0.0, 0.6);
    cairo_show_text(cr, item.text.c_str());

    cairo_move_to(cr, x, y + item.text_height - 4.0);
    cairo_set_source_rgba(cr, item.text_color.red, item.text_color.green,
                          item.text_color.blue, item.text_color.alpha);
    cairo_show_text(cr, item.text.c_str());
  }
}

static gboolean overlay_draw_cb(GtkWidget* widget,
                                cairo_t* cr,
                                gpointer user_data) {
  auto* overlay = static_cast<OverlayWindowState*>(user_data);
  if (overlay == nullptr || widget == nullptr) {
    return FALSE;
  }

  auto* app =
      MY_APPLICATION(g_object_get_data(G_OBJECT(widget), "snotice_app"));
  if (app == nullptr) {
    return FALSE;
  }

  GtkAllocation allocation{};
  gtk_widget_get_allocation(widget, &allocation);

  cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
  cairo_set_source_rgba(cr, 0.0, 0.0, 0.0, 0.0);
  cairo_paint(cr);

  const gint64 now_us = g_get_monotonic_time();
  if (app->overlay_mode == kOverlayFull) {
    const double elapsed_ms = (now_us - app->overlay_start_us) / 1000.0;
    const double total_ms = std::max(1, app->overlay_total_duration_ms);
    const double phase = clamp_double(elapsed_ms / total_ms, 0.0, 1.0);
    const double alpha = std::sin(phase * kPi) * 0.8;

    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    cairo_set_source_rgba(cr, app->overlay_color.red, app->overlay_color.green,
                          app->overlay_color.blue,
                          clamp_double(alpha, 0.0, 0.92));
    cairo_rectangle(cr, 0, 0, allocation.width, allocation.height);
    cairo_fill(cr);
    return TRUE;
  }

  if (app->overlay_mode == kOverlayEdge) {
    const double elapsed_ms = (now_us - app->overlay_start_us) / 1000.0;
    const double cycle_ms = std::max(120.0, static_cast<double>(app->edge_cycle_duration_ms));
    const double cycle_phase = std::fmod(elapsed_ms, cycle_ms) / cycle_ms;
    const double pulse =
        cycle_phase < 0.5 ? cycle_phase * 2.0 : (1.0 - cycle_phase) * 2.0;
    const double alpha = app->edge_min_alpha +
                         (app->edge_max_alpha - app->edge_min_alpha) * pulse;
    const double width = clamp_double(app->edge_line_width, 2.0, 48.0);
    const double inset = std::max(2.0, width / 2.0 + 1.0);
    const double radius = std::max(12.0, width * 2.0);

    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    cairo_set_line_width(cr, width);
    draw_rounded_rect(cr, inset, inset, allocation.width - inset * 2.0,
                      allocation.height - inset * 2.0, radius);
    cairo_set_source_rgba(cr, app->overlay_color.red, app->overlay_color.green,
                          app->overlay_color.blue, clamp_double(alpha, 0.05, 1.0));
    cairo_stroke(cr);
    return TRUE;
  }

  if (app->overlay_mode == kOverlayBarrage) {
    draw_barrage_items(cr, overlay, now_us);
    return TRUE;
  }

  return FALSE;
}

static gboolean overlay_tick_cb(gpointer user_data) {
  auto* self = MY_APPLICATION(user_data);
  if (self == nullptr || self->overlay_windows == nullptr ||
      self->overlay_windows->empty()) {
    self->animation_timer_id = 0;
    return G_SOURCE_REMOVE;
  }

  const gint64 now_us = g_get_monotonic_time();
  if (self->overlay_mode == kOverlayBarrage) {
    bool has_active_items = false;
    for (auto* overlay : *self->overlay_windows) {
      if (overlay == nullptr) {
        continue;
      }
      overlay->barrage_items.erase(
          std::remove_if(
              overlay->barrage_items.begin(), overlay->barrage_items.end(),
              [now_us](const BarrageItem& item) {
                return now_us - item.start_us >=
                       static_cast<gint64>(item.duration_ms) * 1000;
              }),
          overlay->barrage_items.end());
      has_active_items = has_active_items || !overlay->barrage_items.empty();
    }
    if (!has_active_items) {
      clear_overlay_windows(self);
      self->animation_timer_id = 0;
      return G_SOURCE_REMOVE;
    }
    queue_overlay_redraw(self);
    return G_SOURCE_CONTINUE;
  }

  const double elapsed_ms = (now_us - self->overlay_start_us) / 1000.0;
  if (elapsed_ms >= std::max(1, self->overlay_total_duration_ms)) {
    clear_overlay_windows(self);
    self->animation_timer_id = 0;
    return G_SOURCE_REMOVE;
  }

  queue_overlay_redraw(self);
  return G_SOURCE_CONTINUE;
}

static bool trigger_native_full(MyApplication* self, FlValue* args) {
  const int duration_ms = clamp_int(parse_int_arg(args, "duration", 500), 60, 5000);
  const GdkRGBA color = parse_color_arg(args, "color", "#FF0000");

  clear_overlay_windows(self);
  if (!ensure_overlay_windows(self)) {
    return false;
  }

  self->overlay_mode = kOverlayFull;
  self->overlay_color = color;
  self->overlay_start_us = g_get_monotonic_time();
  self->overlay_total_duration_ms = duration_ms;

  start_animation_timer(self, 16);
  queue_overlay_redraw(self);
  return true;
}

static bool trigger_native_edge(MyApplication* self, FlValue* args) {
  const int duration_ms = clamp_int(parse_int_arg(args, "duration", 500), 120, 5000);
  const int repeat_count = std::max(1, parse_int_arg(args, "repeat", 2));
  const double line_width =
      clamp_double(parse_double_arg(args, "width", 14.0), 2.0, 48.0);
  const double opacity =
      clamp_double(parse_double_arg(args, "opacity", 0.92), 0.1, 1.0);
  const GdkRGBA color = parse_color_arg(args, "color", "#FF0000");

  clear_overlay_windows(self);
  if (!ensure_overlay_windows(self)) {
    return false;
  }

  self->overlay_mode = kOverlayEdge;
  self->overlay_color = color;
  self->overlay_start_us = g_get_monotonic_time();
  self->edge_cycle_duration_ms = duration_ms;
  self->overlay_total_duration_ms = duration_ms * repeat_count;
  self->edge_line_width = line_width;
  self->edge_max_alpha = opacity;
  self->edge_min_alpha = clamp_double(opacity * 0.24, 0.03, 0.7);

  start_animation_timer(self, 16);
  queue_overlay_redraw(self);
  return true;
}

static bool trigger_native_barrage(MyApplication* self, FlValue* args) {
  std::string text = trim(parse_string_arg(args, "text", "SNotice"));
  if (text.empty()) {
    text = "SNotice";
  }
  const int duration_ms =
      clamp_int(parse_int_arg(args, "duration", 6000), 300, 60000);
  const double speed =
      clamp_double(parse_double_arg(args, "speed", 120.0), 20.0, 2000.0);
  const double font_size =
      clamp_double(parse_double_arg(args, "fontSize", 28.0), 12.0, 96.0);
  const int repeat_count =
      clamp_int(parse_int_arg(args, "repeat", 1), 1, 8);
  const GdkRGBA color = parse_color_arg(args, "color", "#FFFFFF");
  const BarrageLane lane = parse_barrage_lane(
      to_lower(parse_string_arg(args, "lane", "top")));

  const bool reuse_existing =
      self->overlay_mode == kOverlayBarrage &&
      self->overlay_windows != nullptr && !self->overlay_windows->empty();
  if (!reuse_existing) {
    clear_overlay_windows(self);
    if (!ensure_overlay_windows(self)) {
      return false;
    }
  }

  self->overlay_mode = kOverlayBarrage;
  for (auto* overlay : *self->overlay_windows) {
    append_barrage_items(overlay, text, color, duration_ms, speed, font_size,
                         lane, repeat_count);
  }

  start_animation_timer(self, 12);
  queue_overlay_redraw(self);
  return true;
}

static void handle_flash_method_call(MyApplication* self, FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  if (g_strcmp0(method, "triggerFlash") != 0) {
    fl_method_call_respond_not_implemented(method_call, nullptr);
    return;
  }

  FlValue* args = fl_method_call_get_args(method_call);
  if (args != nullptr && fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    fl_method_call_respond_error(method_call, "invalid_args",
                                 "Expected map arguments", nullptr, nullptr);
    return;
  }

  const std::string effect = to_lower(parse_string_arg(args, "effect", "full"));
  bool handled = false;
  if (effect == "barrage") {
    handled = trigger_native_barrage(self, args);
  } else if (is_edge_effect(effect)) {
    handled = trigger_native_edge(self, args);
  } else if (effect == "full") {
    handled = trigger_native_full(self, args);
  }

  fl_method_call_respond_success(method_call, fl_value_new_bool(handled), nullptr);
}

static void flash_method_call_cb(FlMethodChannel* channel,
                                 FlMethodCall* method_call,
                                 gpointer user_data) {
  auto* self = MY_APPLICATION(user_data);
  handle_flash_method_call(self, method_call);
}

static void register_flash_channel(MyApplication* self, FlView* view) {
  FlPluginRegistry* registry = FL_PLUGIN_REGISTRY(view);
  g_autoptr(FlPluginRegistrar) registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SNoticeFlashChannel");
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->flash_channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), "snotice/flash",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->flash_channel,
                                            flash_method_call_cb, self, nullptr);
}

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "SNotice");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "SNotice");
  }

  gtk_window_set_default_size(window, 1280, 720);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
  desktop_multi_window_plugin_set_window_created_callback(
      [](FlPluginRegistry* registry) { fl_register_plugins(registry); });
  register_flash_channel(self, view);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  auto* self = MY_APPLICATION(application);
  clear_overlay_windows(self);
  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  clear_overlay_windows(self);
  if (self->overlay_windows != nullptr) {
    delete self->overlay_windows;
    self->overlay_windows = nullptr;
  }
  g_clear_object(&self->flash_channel);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {
  self->flash_channel = nullptr;
  self->overlay_windows = new std::vector<OverlayWindowState*>();
  self->animation_timer_id = 0;
  self->overlay_mode = kOverlayNone;
  self->overlay_start_us = 0;
  self->overlay_total_duration_ms = 0;
  self->edge_cycle_duration_ms = 500;
  self->edge_line_width = 14.0;
  self->edge_min_alpha = 0.2;
  self->edge_max_alpha = 0.92;
  gdk_rgba_parse(&self->overlay_color, "#FF0000");
}

MyApplication* my_application_new() {
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
