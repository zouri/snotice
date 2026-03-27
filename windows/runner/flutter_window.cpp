#include "flutter_window.h"

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <optional>
#include <string>
#include <vector>
#include <mmsystem.h>

#include <flutter/standard_method_codec.h>

#include "desktop_multi_window/desktop_multi_window_plugin.h"
#include "flutter/generated_plugin_registrant.h"

namespace {

constexpr COLORREF kTransparentColorKey = RGB(1, 0, 1);

struct MonitorEnumContext {
  FlutterWindow* window = nullptr;
  COLORREF color = RGB(255, 0, 0);
};

struct EdgeMonitorEnumContext {
  FlutterWindow* window = nullptr;
  COLORREF color = RGB(255, 0, 0);
  int line_width = 14;
};

struct BarrageMonitorEnumContext {
  FlutterWindow* window = nullptr;
  std::wstring text = L"SNotice";
  COLORREF color = RGB(255, 255, 255);
  int duration_ms = 6000;
  double speed = 120.0;
  int font_size = 28;
  std::string lane = "top";
  int repeat_count = 1;
};

struct EdgeOverlayState {
  COLORREF color = RGB(255, 0, 0);
  int line_width = 14;
};

struct BarrageItemLayout {
  std::wstring text = L"SNotice";
  COLORREF text_color = RGB(255, 255, 255);
  HFONT font = nullptr;
  int text_length = 0;
  int text_width = 0;
  int text_height = 0;
  int bubble_padding_x = 16;
  int bubble_padding_y = 8;
  int bubble_radius = 14;
  DWORD start_tick = 0;
  int duration_ms = 6000;
  double start_x = 0.0;
  double end_x = 0.0;
  double row_top = 0.0;
  double spawn_offset_x = 0.0;
  double end_extra = 0.0;
  double initial_progress = 0.0;
  double speed_factor = 1.0;
};

struct BarrageOverlayState {
  HBRUSH clear_brush = nullptr;
  HBRUSH bubble_brush = nullptr;
  HPEN bubble_pen = nullptr;
  HDC buffer_dc = nullptr;
  HBITMAP buffer_bitmap = nullptr;
  HBITMAP buffer_old_bitmap = nullptr;
  int buffer_width = 0;
  int buffer_height = 0;
  std::vector<BarrageItemLayout> items;
};

double RandomBetween(std::mt19937& rng, double min, double max) {
  std::uniform_real_distribution<double> distribution(min, max);
  return distribution(rng);
}

double ClampDouble(double value, double min, double max) {
  return std::max(min, std::min(max, value));
}

std::string Trim(const std::string& value) {
  const auto first = value.find_first_not_of(" \t\r\n");
  if (first == std::string::npos) {
    return "";
  }
  const auto last = value.find_last_not_of(" \t\r\n");
  return value.substr(first, last - first + 1);
}

double LaneFactor(const std::string& lane) {
  if (lane == "middle") {
    return 0.5;
  }
  if (lane == "bottom") {
    return 0.82;
  }
  return 0.18;
}

double MiddleSignedStep(int index) {
  if (index == 0) {
    return 0.0;
  }
  const double level = static_cast<double>((index + 1) / 2);
  return index % 2 == 1 ? level : -level;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project), random_engine_(std::random_device{}()) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }

  RegisterPlugins(flutter_controller_->engine());
  DesktopMultiWindowSetWindowCreatedCallback([](void* controller) {
    auto* flutter_view_controller =
        reinterpret_cast<flutter::FlutterViewController*>(controller);
    auto* registry = flutter_view_controller->engine();
    RegisterPlugins(registry);
  });

  RegisterFlashChannel();
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() { this->Show(); });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  ClearFlashOverlayWindows();
  flash_channel_.reset();

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd,
                                      UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (message == WM_TIMER && wparam == kFlashOverlayCloseTimerId) {
    ClearFlashOverlayWindows();
    return 0;
  }

  if (message == WM_TIMER && wparam == kFlashOverlayAnimationTimerId) {
    TickNativeAnimation();
    return 0;
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::RegisterFlashChannel() {
  flash_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "snotice/flash",
          &flutter::StandardMethodCodec::GetInstance());

  flash_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) { HandleFlashMethodCall(call, std::move(result)); });
}

void FlutterWindow::HandleFlashMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (call.method_name() != "triggerFlash") {
    result->NotImplemented();
    return;
  }

  const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
  if (args == nullptr) {
    result->Error("invalid_args", "Expected map arguments");
    return;
  }

  result->Success(flutter::EncodableValue(TriggerNativeFlash(*args)));
}

bool FlutterWindow::TriggerNativeFlash(const flutter::EncodableMap& args) {
  const std::string effect =
      ToLower(ParseStringArgument(args, "effect", "full"));

  if (effect == "barrage") {
    return TriggerNativeBarrage(args);
  }
  if (IsEdgeEffect(effect)) {
    return TriggerNativeEdge(args);
  }
  if (effect == "full") {
    return TriggerNativeFull(args);
  }

  return false;
}

bool FlutterWindow::TriggerNativeFull(const flutter::EncodableMap& args) {
  const int duration_ms =
      std::max(60, std::min(5000, ParseIntArgument(args, "duration", 500)));
  const COLORREF color = ParseColor(ParseStringArgument(args, "color", "#FF0000"));

  ClearFlashOverlayWindows();
  EnsureFlashOverlayClassRegistered();

  MonitorEnumContext context;
  context.window = this;
  context.color = color;

  EnumDisplayMonitors(nullptr, nullptr, EnumDisplayMonitorsProc,
                      reinterpret_cast<LPARAM>(&context));
  if (flash_overlay_windows_.empty()) {
    return false;
  }

  if (SetTimer(GetHandle(), kFlashOverlayCloseTimerId, duration_ms, nullptr) ==
      0) {
    ClearFlashOverlayWindows();
    return false;
  }
  return true;
}

bool FlutterWindow::TriggerNativeEdge(const flutter::EncodableMap& args) {
  const int duration_ms =
      std::max(120, std::min(5000, ParseIntArgument(args, "duration", 500)));
  const int repeat_count = std::max(1, ParseIntArgument(args, "repeat", 2));
  const int line_width = static_cast<int>(std::round(ClampDouble(
      ParseDoubleArgument(args, "width", 14.0), 2.0, 48.0)));
  const double opacity =
      ClampDouble(ParseDoubleArgument(args, "opacity", 0.92), 0.1, 1.0);
  const COLORREF color = ParseColor(ParseStringArgument(args, "color", "#FF0000"));

  ClearFlashOverlayWindows();
  EnsureEdgeOverlayClassRegistered();

  EdgeMonitorEnumContext context;
  context.window = this;
  context.color = color;
  context.line_width = line_width;

  EnumDisplayMonitors(nullptr, nullptr, EnumDisplayMonitorsEdgeProc,
                      reinterpret_cast<LPARAM>(&context));
  if (flash_overlay_windows_.empty()) {
    return false;
  }

  native_overlay_mode_ = NativeOverlayMode::kEdge;
  native_overlay_start_tick_ = GetTickCount();
  edge_cycle_duration_ms_ = duration_ms;
  native_overlay_total_duration_ms_ = duration_ms * repeat_count;
  edge_max_alpha_ =
      static_cast<BYTE>(ClampDouble(opacity * 255.0, 40.0, 255.0));
  edge_min_alpha_ =
      static_cast<BYTE>(ClampDouble(edge_max_alpha_ * 0.24, 8.0, 180.0));

  TickNativeAnimation();
  StartAnimationTimer();
  return true;
}

bool FlutterWindow::TriggerNativeBarrage(const flutter::EncodableMap& args) {
  std::string text = Trim(ParseStringArgument(args, "text", "SNotice"));
  if (text.empty()) {
    text = "SNotice";
  }

  const int duration_ms =
      std::max(300, std::min(60000, ParseIntArgument(args, "duration", 6000)));
  const double speed =
      ClampDouble(ParseDoubleArgument(args, "speed", 120.0), 20.0, 2000.0);
  const int font_size = static_cast<int>(std::round(ClampDouble(
      ParseDoubleArgument(args, "fontSize", 28.0), 12.0, 96.0)));
  std::string lane = ToLower(ParseStringArgument(args, "lane", "top"));
  if (lane != "top" && lane != "middle" && lane != "bottom") {
    lane = "top";
  }
  const int repeat_count =
      std::max(1, std::min(8, ParseIntArgument(args, "repeat", 1)));
  const COLORREF color = ParseColor(ParseStringArgument(args, "color", "#FFFFFF"));

  const std::wstring utf16_text = [&]() -> std::wstring {
    std::wstring value = Utf16FromUtf8(text);
    if (value.empty()) {
      value = L"SNotice";
    }
    return value;
  }();

  const bool reuse_existing =
      native_overlay_mode_ == NativeOverlayMode::kBarrage &&
      !flash_overlay_windows_.empty();

  EnsureBarrageOverlayClassRegistered();
  if (reuse_existing) {
    for (const auto& overlay : flash_overlay_windows_) {
      if (overlay.kind != OverlayWindowKind::kBarrage ||
          overlay.hwnd == nullptr || !IsWindow(overlay.hwnd)) {
        continue;
      }
      AppendBarrageItemsToOverlay(overlay.hwnd, utf16_text, color, duration_ms,
                                  speed, font_size, lane, repeat_count);
    }
    TickNativeAnimation();
    StartAnimationTimer();
    return true;
  }

  ClearFlashOverlayWindows();
  native_overlay_mode_ = NativeOverlayMode::kBarrage;
  native_overlay_start_tick_ = GetTickCount();
  native_overlay_total_duration_ms_ = 0;

  BarrageMonitorEnumContext context;
  context.window = this;
  context.text = utf16_text;
  context.color = color;
  context.duration_ms = duration_ms;
  context.speed = speed;
  context.font_size = font_size;
  context.lane = lane;
  context.repeat_count = repeat_count;

  EnumDisplayMonitors(nullptr, nullptr, EnumDisplayMonitorsBarrageProc,
                      reinterpret_cast<LPARAM>(&context));
  if (flash_overlay_windows_.empty()) {
    return false;
  }
  TickNativeAnimation();
  StartAnimationTimer();
  return true;
}

bool FlutterWindow::IsEdgeEffect(const std::string& effect) {
  return effect == "edge" || effect == "edge_sweep" || effect == "sweep" ||
         effect == "edge_pulse" || effect == "pulse" ||
         effect == "edge_dual" || effect == "dual" ||
         effect == "edge_dash" || effect == "dash" ||
         effect == "edge_corner" || effect == "corner" ||
         effect == "edge_rainbow" || effect == "rainbow";
}

void FlutterWindow::TickNativeAnimation() {
  if (native_overlay_mode_ == NativeOverlayMode::kNone) {
    return;
  }

  if (native_overlay_mode_ == NativeOverlayMode::kEdge) {
    const DWORD elapsed = GetTickCount() - native_overlay_start_tick_;
    if (elapsed >=
        static_cast<DWORD>(std::max(1, native_overlay_total_duration_ms_))) {
      ClearFlashOverlayWindows();
      return;
    }

    const int cycle = std::max(120, edge_cycle_duration_ms_);
    const double cycle_phase =
        static_cast<double>(elapsed % cycle) / static_cast<double>(cycle);
    const double pulse =
        cycle_phase < 0.5 ? cycle_phase * 2.0 : (1.0 - cycle_phase) * 2.0;
    const BYTE alpha = static_cast<BYTE>(
        std::round(edge_min_alpha_ +
                   (edge_max_alpha_ - edge_min_alpha_) * pulse));

    for (const auto& overlay : flash_overlay_windows_) {
      if (overlay.kind != OverlayWindowKind::kEdge || overlay.hwnd == nullptr ||
          !IsWindow(overlay.hwnd)) {
        continue;
      }
      SetLayeredWindowAttributes(overlay.hwnd, kTransparentColorKey, alpha,
                                 LWA_ALPHA | LWA_COLORKEY);
      InvalidateRect(overlay.hwnd, nullptr, FALSE);
    }
    return;
  }

  if (native_overlay_mode_ == NativeOverlayMode::kBarrage) {
    bool has_active_item = false;
    const DWORD now = GetTickCount();
    for (const auto& overlay : flash_overlay_windows_) {
      if (overlay.kind != OverlayWindowKind::kBarrage ||
          overlay.hwnd == nullptr || !IsWindow(overlay.hwnd)) {
        continue;
      }
      auto* state = reinterpret_cast<BarrageOverlayState*>(
          GetWindowLongPtr(overlay.hwnd, GWLP_USERDATA));
      if (state == nullptr) {
        continue;
      }
      state->items.erase(
          std::remove_if(
              state->items.begin(), state->items.end(),
              [now](BarrageItemLayout& item) {
                const bool expired =
                    now - item.start_tick >=
                    static_cast<DWORD>(std::max(1, item.duration_ms));
                if (expired && item.font != nullptr) {
                  DeleteObject(item.font);
                  item.font = nullptr;
                }
                return expired;
              }),
          state->items.end());
      has_active_item = has_active_item || !state->items.empty();
      // Barrage rendering is light enough for full invalidation each frame.
      InvalidateRect(overlay.hwnd, nullptr, FALSE);
    }
    if (!has_active_item) {
      ClearFlashOverlayWindows();
    }
  }
}

void FlutterWindow::ClearFlashOverlayWindows() {
  CancelTimers();

  for (const auto& overlay : flash_overlay_windows_) {
    if (overlay.hwnd != nullptr && IsWindow(overlay.hwnd)) {
      DestroyWindow(overlay.hwnd);
    }
  }
  flash_overlay_windows_.clear();

  native_overlay_mode_ = NativeOverlayMode::kNone;
  native_overlay_start_tick_ = 0;
  native_overlay_total_duration_ms_ = 0;
}

void FlutterWindow::CancelTimers() {
  if (GetHandle() == nullptr) {
    if (high_resolution_timer_enabled_) {
      timeEndPeriod(1);
      high_resolution_timer_enabled_ = false;
    }
    return;
  }
  KillTimer(GetHandle(), kFlashOverlayCloseTimerId);
  KillTimer(GetHandle(), kFlashOverlayAnimationTimerId);
  if (high_resolution_timer_enabled_) {
    timeEndPeriod(1);
    high_resolution_timer_enabled_ = false;
  }
}

void FlutterWindow::StartAnimationTimer() {
  if (GetHandle() == nullptr) {
    return;
  }
  // Improve WM_TIMER cadence for smoother native overlay movement.
  if (!high_resolution_timer_enabled_ && timeBeginPeriod(1) == TIMERR_NOERROR) {
    high_resolution_timer_enabled_ = true;
  }

  // Barrage benefits from a slightly tighter tick than edge flash.
  const UINT timer_interval_ms =
      native_overlay_mode_ == NativeOverlayMode::kBarrage ? 12 : 16;
  SetTimer(GetHandle(), kFlashOverlayAnimationTimerId, timer_interval_ms,
           nullptr);
}

void FlutterWindow::EnsureFlashOverlayClassRegistered() {
  if (flash_overlay_class_registered_) {
    return;
  }

  WNDCLASSW overlay_class = {};
  overlay_class.lpfnWndProc = FlashOverlayWndProc;
  overlay_class.hInstance = GetModuleHandle(nullptr);
  overlay_class.lpszClassName = kFlashOverlayClassName;
  overlay_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  overlay_class.hbrBackground = nullptr;
  overlay_class.style = CS_HREDRAW | CS_VREDRAW;

  if (RegisterClassW(&overlay_class) != 0 ||
      GetLastError() == ERROR_CLASS_ALREADY_EXISTS) {
    flash_overlay_class_registered_ = true;
  }
}

void FlutterWindow::EnsureEdgeOverlayClassRegistered() {
  if (edge_overlay_class_registered_) {
    return;
  }

  WNDCLASSW overlay_class = {};
  overlay_class.lpfnWndProc = EdgeOverlayWndProc;
  overlay_class.hInstance = GetModuleHandle(nullptr);
  overlay_class.lpszClassName = kEdgeOverlayClassName;
  overlay_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  overlay_class.hbrBackground = nullptr;
  overlay_class.style = CS_HREDRAW | CS_VREDRAW;

  if (RegisterClassW(&overlay_class) != 0 ||
      GetLastError() == ERROR_CLASS_ALREADY_EXISTS) {
    edge_overlay_class_registered_ = true;
  }
}

void FlutterWindow::EnsureBarrageOverlayClassRegistered() {
  if (barrage_overlay_class_registered_) {
    return;
  }

  WNDCLASSW overlay_class = {};
  overlay_class.lpfnWndProc = BarrageOverlayWndProc;
  overlay_class.hInstance = GetModuleHandle(nullptr);
  overlay_class.lpszClassName = kBarrageOverlayClassName;
  overlay_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  overlay_class.hbrBackground = nullptr;
  overlay_class.style = CS_HREDRAW | CS_VREDRAW;

  if (RegisterClassW(&overlay_class) != 0 ||
      GetLastError() == ERROR_CLASS_ALREADY_EXISTS) {
    barrage_overlay_class_registered_ = true;
  }
}

void FlutterWindow::CreateFlashOverlayForMonitor(const RECT& bounds,
                                                 COLORREF color) {
  const int width = bounds.right - bounds.left;
  const int height = bounds.bottom - bounds.top;
  if (width <= 0 || height <= 0) {
    return;
  }

  HWND overlay = CreateWindowExW(
      WS_EX_LAYERED | WS_EX_TOPMOST | WS_EX_TOOLWINDOW | WS_EX_TRANSPARENT |
          WS_EX_NOACTIVATE,
      kFlashOverlayClassName, L"", WS_POPUP, bounds.left, bounds.top, width,
      height, nullptr, nullptr, GetModuleHandle(nullptr), nullptr);
  if (overlay == nullptr) {
    return;
  }

  auto* brush = CreateSolidBrush(color);
  SetWindowLongPtr(overlay, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(brush));

  SetLayeredWindowAttributes(overlay, 0, 212, LWA_ALPHA);
  SetWindowPos(overlay, HWND_TOPMOST, bounds.left, bounds.top, width, height,
               SWP_SHOWWINDOW | SWP_NOACTIVATE);
  UpdateWindow(overlay);

  flash_overlay_windows_.push_back({overlay, OverlayWindowKind::kFull});
}

void FlutterWindow::CreateEdgeOverlayForMonitor(const RECT& bounds,
                                                COLORREF color,
                                                int line_width) {
  const int width = bounds.right - bounds.left;
  const int height = bounds.bottom - bounds.top;
  if (width <= 0 || height <= 0) {
    return;
  }

  HWND overlay = CreateWindowExW(
      WS_EX_LAYERED | WS_EX_TOPMOST | WS_EX_TOOLWINDOW | WS_EX_TRANSPARENT |
          WS_EX_NOACTIVATE,
      kEdgeOverlayClassName, L"", WS_POPUP, bounds.left, bounds.top, width,
      height, nullptr, nullptr, GetModuleHandle(nullptr), nullptr);
  if (overlay == nullptr) {
    return;
  }

  auto* state = new EdgeOverlayState();
  state->color = color;
  state->line_width = std::max(1, line_width);
  SetWindowLongPtr(overlay, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(state));

  SetLayeredWindowAttributes(overlay, kTransparentColorKey, edge_max_alpha_,
                             LWA_ALPHA | LWA_COLORKEY);
  SetWindowPos(overlay, HWND_TOPMOST, bounds.left, bounds.top, width, height,
               SWP_SHOWWINDOW | SWP_NOACTIVATE);
  UpdateWindow(overlay);

  flash_overlay_windows_.push_back({overlay, OverlayWindowKind::kEdge});
}

void FlutterWindow::CreateBarrageOverlayForMonitor(const RECT& bounds,
                                                   const std::wstring& text,
                                                   COLORREF color,
                                                   int duration_ms,
                                                   double speed,
                                                   int font_size,
                                                   const std::string& lane,
                                                   int repeat_count) {
  const int width = bounds.right - bounds.left;
  const int height = bounds.bottom - bounds.top;
  if (width <= 0 || height <= 0) {
    return;
  }

  HWND overlay = CreateWindowExW(
      WS_EX_LAYERED | WS_EX_TOPMOST | WS_EX_TOOLWINDOW | WS_EX_TRANSPARENT |
          WS_EX_NOACTIVATE,
      kBarrageOverlayClassName, L"", WS_POPUP, bounds.left, bounds.top, width,
      height, nullptr, nullptr, GetModuleHandle(nullptr), nullptr);
  if (overlay == nullptr) {
    return;
  }

  auto* state = new BarrageOverlayState();
  state->clear_brush = CreateSolidBrush(kTransparentColorKey);
  state->bubble_brush = CreateSolidBrush(RGB(24, 24, 24));
  state->bubble_pen = CreatePen(PS_SOLID, 1, RGB(186, 186, 186));

  state->buffer_width = width;
  state->buffer_height = height;

  SetWindowLongPtr(overlay, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(state));
  AppendBarrageItemsToOverlay(overlay, text, color, duration_ms, speed,
                              font_size, lane, repeat_count);

  HDC overlay_dc = GetDC(overlay);
  // Draw into an off-screen bitmap, then blit once to reduce visible flicker.
  if (overlay_dc != nullptr && state->buffer_width > 0 && state->buffer_height > 0) {
    state->buffer_dc = CreateCompatibleDC(overlay_dc);
    if (state->buffer_dc != nullptr) {
      state->buffer_bitmap = CreateCompatibleBitmap(
          overlay_dc, state->buffer_width, state->buffer_height);
      if (state->buffer_bitmap != nullptr) {
        state->buffer_old_bitmap = reinterpret_cast<HBITMAP>(
            SelectObject(state->buffer_dc, state->buffer_bitmap));
      } else {
        DeleteDC(state->buffer_dc);
        state->buffer_dc = nullptr;
      }
    }
    ReleaseDC(overlay, overlay_dc);
  }

  SetLayeredWindowAttributes(overlay, kTransparentColorKey, 255, LWA_COLORKEY);
  SetWindowPos(overlay, HWND_TOPMOST, bounds.left, bounds.top, width, height,
               SWP_SHOWWINDOW | SWP_NOACTIVATE);
  UpdateWindow(overlay);

  flash_overlay_windows_.push_back({overlay, OverlayWindowKind::kBarrage});
}

void FlutterWindow::AppendBarrageItemsToOverlay(HWND overlay,
                                                const std::wstring& text,
                                                COLORREF color,
                                                int duration_ms,
                                                double speed,
                                                int font_size,
                                                const std::string& lane,
                                                int repeat_count) {
  if (overlay == nullptr || !IsWindow(overlay)) {
    return;
  }
  auto* state = reinterpret_cast<BarrageOverlayState*>(
      GetWindowLongPtr(overlay, GWLP_USERDATA));
  if (state == nullptr) {
    return;
  }

  RECT rect{};
  if (!GetClientRect(overlay, &rect)) {
    return;
  }
  const int width = rect.right - rect.left;
  const int height = rect.bottom - rect.top;
  if (width <= 0 || height <= 0) {
    return;
  }

  HFONT measure_font = CreateFontW(-font_size, 0, 0, 0, FW_BOLD, FALSE, FALSE,
                                   FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
                                   CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY,
                                   DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");
  HDC dc = GetDC(overlay);
  HFONT old_font = nullptr;
  if (dc != nullptr && measure_font != nullptr) {
    old_font = reinterpret_cast<HFONT>(SelectObject(dc, measure_font));
  }

  SIZE text_size{};
  if (dc == nullptr || !GetTextExtentPoint32W(dc, text.c_str(),
                                               static_cast<int>(text.size()),
                                               &text_size)) {
    text_size.cx = 140;
    text_size.cy = std::max(20, font_size);
  }

  if (dc != nullptr && old_font != nullptr) {
    SelectObject(dc, old_font);
  }
  if (dc != nullptr) {
    ReleaseDC(overlay, dc);
  }
  if (measure_font != nullptr) {
    DeleteObject(measure_font);
  }

  const int text_width = std::max(40, static_cast<int>(text_size.cx));
  const int text_height = std::max(20, static_cast<int>(text_size.cy));
  const double lane_y = static_cast<double>(height) * LaneFactor(lane);
  const double row_spacing =
      std::max(36.0, std::min(120.0, static_cast<double>(text_height) + 12.0));
  const auto clamp_top = [&](double top) -> double {
    const double max_top = std::max(0.0, static_cast<double>(height - text_height));
    return ClampDouble(top, 0.0, max_top);
  };

  const DWORD now = GetTickCount();
  state->items.reserve(state->items.size() + repeat_count);
  for (int index = 0; index < repeat_count; ++index) {
    const double raw_top = [&]() -> double {
      if (lane == "bottom") {
        return lane_y - index * row_spacing;
      }
      if (lane == "middle") {
        return lane_y + MiddleSignedStep(index) * row_spacing;
      }
      return lane_y + index * row_spacing;
    }();

    const double jitter =
        RandomBetween(random_engine_, -row_spacing * 0.35, row_spacing * 0.35);
    const double spawn_offset_x =
        RandomBetween(random_engine_, -width * 0.18, width * 0.35);
    const double end_extra = RandomBetween(random_engine_, 0.0, width * 0.2);
    const double initial_progress = RandomBetween(random_engine_, 0.06, 0.42);
    const double speed_factor = RandomBetween(random_engine_, 0.82, 1.2);
    const double start_x = static_cast<double>(width) + 40.0 + spawn_offset_x;
    const double end_x = -static_cast<double>(text_width) - 60.0 - end_extra;
    const double adjusted_speed = std::max(1.0, speed) * speed_factor * 0.82;
    const double start_x_now = start_x + (end_x - start_x) * initial_progress;
    const double remaining_distance = std::max(1.0, start_x_now - end_x);
    const double remaining_travel_seconds = remaining_distance / adjusted_speed;
    const double requested_seconds = std::max(0.6, duration_ms / 1000.0);
    const double animation_seconds = std::max(
        requested_seconds * (1.0 - initial_progress * 0.55),
        remaining_travel_seconds);

    BarrageItemLayout item;
    item.text = text;
    item.text_color = color;
    item.font = CreateFontW(-font_size, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
                            DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
                            CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY,
                            DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");
    item.text_length = static_cast<int>(text.size());
    item.text_width = text_width;
    item.text_height = text_height;
    item.start_tick = now;
    item.duration_ms = std::max(1, static_cast<int>(std::round(animation_seconds * 1000.0)));
    item.start_x = start_x;
    item.end_x = end_x;
    item.row_top = clamp_top(raw_top + jitter);
    item.spawn_offset_x = spawn_offset_x;
    item.end_extra = end_extra;
    item.initial_progress = initial_progress;
    item.speed_factor = speed_factor;
    state->items.push_back(item);
  }
  std::shuffle(state->items.begin(), state->items.end(), random_engine_);
}

BOOL CALLBACK FlutterWindow::EnumDisplayMonitorsProc(HMONITOR monitor,
                                                     HDC hdc,
                                                     LPRECT rect,
                                                     LPARAM data) {
  auto* context = reinterpret_cast<MonitorEnumContext*>(data);
  if (context == nullptr || context->window == nullptr || rect == nullptr) {
    return TRUE;
  }

  MONITORINFO monitor_info = {};
  monitor_info.cbSize = sizeof(MONITORINFO);
  if (GetMonitorInfo(monitor, &monitor_info)) {
    context->window->CreateFlashOverlayForMonitor(monitor_info.rcMonitor,
                                                  context->color);
    return TRUE;
  }

  context->window->CreateFlashOverlayForMonitor(*rect, context->color);
  return TRUE;
}

BOOL CALLBACK FlutterWindow::EnumDisplayMonitorsEdgeProc(HMONITOR monitor,
                                                         HDC hdc,
                                                         LPRECT rect,
                                                         LPARAM data) {
  auto* context = reinterpret_cast<EdgeMonitorEnumContext*>(data);
  if (context == nullptr || context->window == nullptr || rect == nullptr) {
    return TRUE;
  }

  MONITORINFO monitor_info = {};
  monitor_info.cbSize = sizeof(MONITORINFO);
  if (GetMonitorInfo(monitor, &monitor_info)) {
    context->window->CreateEdgeOverlayForMonitor(monitor_info.rcMonitor,
                                                 context->color,
                                                 context->line_width);
    return TRUE;
  }

  context->window->CreateEdgeOverlayForMonitor(*rect, context->color,
                                               context->line_width);
  return TRUE;
}

BOOL CALLBACK FlutterWindow::EnumDisplayMonitorsBarrageProc(HMONITOR monitor,
                                                            HDC hdc,
                                                            LPRECT rect,
                                                            LPARAM data) {
  auto* context = reinterpret_cast<BarrageMonitorEnumContext*>(data);
  if (context == nullptr || context->window == nullptr || rect == nullptr) {
    return TRUE;
  }

  MONITORINFO monitor_info = {};
  monitor_info.cbSize = sizeof(MONITORINFO);
  if (GetMonitorInfo(monitor, &monitor_info)) {
    context->window->CreateBarrageOverlayForMonitor(
        monitor_info.rcMonitor, context->text, context->color,
        context->duration_ms, context->speed, context->font_size, context->lane,
        context->repeat_count);
    return TRUE;
  }

  context->window->CreateBarrageOverlayForMonitor(
      *rect, context->text, context->color, context->duration_ms, context->speed,
      context->font_size, context->lane, context->repeat_count);
  return TRUE;
}

LRESULT CALLBACK FlutterWindow::FlashOverlayWndProc(HWND hwnd,
                                                    UINT message,
                                                    WPARAM wparam,
                                                    LPARAM lparam) noexcept {
  switch (message) {
    case WM_NCHITTEST:
      return HTTRANSPARENT;
    case WM_MOUSEACTIVATE:
      return MA_NOACTIVATE;
    case WM_ERASEBKGND: {
      auto* brush =
          reinterpret_cast<HBRUSH>(GetWindowLongPtr(hwnd, GWLP_USERDATA));
      if (brush == nullptr) {
        return 0;
      }
      RECT rect;
      GetClientRect(hwnd, &rect);
      FillRect(reinterpret_cast<HDC>(wparam), &rect, brush);
      return 1;
    }
    case WM_PAINT: {
      PAINTSTRUCT paint = {};
      HDC dc = BeginPaint(hwnd, &paint);
      auto* brush =
          reinterpret_cast<HBRUSH>(GetWindowLongPtr(hwnd, GWLP_USERDATA));
      if (brush != nullptr) {
        FillRect(dc, &paint.rcPaint, brush);
      }
      EndPaint(hwnd, &paint);
      return 0;
    }
    case WM_NCDESTROY: {
      auto* brush =
          reinterpret_cast<HBRUSH>(GetWindowLongPtr(hwnd, GWLP_USERDATA));
      if (brush != nullptr) {
        DeleteObject(brush);
        SetWindowLongPtr(hwnd, GWLP_USERDATA, 0);
      }
      break;
    }
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

LRESULT CALLBACK FlutterWindow::EdgeOverlayWndProc(HWND hwnd,
                                                   UINT message,
                                                   WPARAM wparam,
                                                   LPARAM lparam) noexcept {
  switch (message) {
    case WM_NCHITTEST:
      return HTTRANSPARENT;
    case WM_MOUSEACTIVATE:
      return MA_NOACTIVATE;
    case WM_ERASEBKGND:
      return 1;
    case WM_PAINT: {
      auto* state = reinterpret_cast<EdgeOverlayState*>(
          GetWindowLongPtr(hwnd, GWLP_USERDATA));
      PAINTSTRUCT paint = {};
      HDC dc = BeginPaint(hwnd, &paint);
      if (state != nullptr) {
        RECT client_rect;
        GetClientRect(hwnd, &client_rect);
        HBRUSH clear_brush = CreateSolidBrush(kTransparentColorKey);
        FillRect(dc, &client_rect, clear_brush);
        DeleteObject(clear_brush);

        HPEN pen = CreatePen(PS_SOLID, std::max(1, state->line_width),
                             state->color);
        HGDIOBJ old_pen = SelectObject(dc, pen);
        HGDIOBJ old_brush = SelectObject(dc, GetStockObject(NULL_BRUSH));

        const int inset = std::max(2, state->line_width / 2 + 1);
        const int radius = std::max(12, state->line_width * 2);
        RoundRect(dc, inset, inset, client_rect.right - inset,
                  client_rect.bottom - inset, radius, radius);

        SelectObject(dc, old_brush);
        SelectObject(dc, old_pen);
        DeleteObject(pen);
      }
      EndPaint(hwnd, &paint);
      return 0;
    }
    case WM_NCDESTROY: {
      auto* state = reinterpret_cast<EdgeOverlayState*>(
          GetWindowLongPtr(hwnd, GWLP_USERDATA));
      delete state;
      SetWindowLongPtr(hwnd, GWLP_USERDATA, 0);
      break;
    }
  }

  return DefWindowProc(hwnd, message, wparam, lparam);
}

LRESULT CALLBACK FlutterWindow::BarrageOverlayWndProc(HWND hwnd,
                                                      UINT message,
                                                      WPARAM wparam,
                                                      LPARAM lparam) noexcept {
  switch (message) {
    case WM_NCHITTEST:
      return HTTRANSPARENT;
    case WM_MOUSEACTIVATE:
      return MA_NOACTIVATE;
    case WM_ERASEBKGND:
      return 1;
    case WM_PAINT: {
      auto* state = reinterpret_cast<BarrageOverlayState*>(
          GetWindowLongPtr(hwnd, GWLP_USERDATA));
      PAINTSTRUCT paint = {};
      HDC dc = BeginPaint(hwnd, &paint);
      if (state != nullptr) {
        HDC render_dc = dc;
        bool use_back_buffer = false;
        if (state->buffer_dc != nullptr && state->buffer_bitmap != nullptr &&
            state->buffer_width > 0 && state->buffer_height > 0) {
          use_back_buffer = true;
          render_dc = state->buffer_dc;
        }

        HBRUSH clear_brush = state->clear_brush;
        bool owns_clear_brush = false;
        if (clear_brush == nullptr) {
          clear_brush = CreateSolidBrush(kTransparentColorKey);
          owns_clear_brush = true;
        }
        if (use_back_buffer) {
          RECT buffer_rect = {0, 0, state->buffer_width, state->buffer_height};
          FillRect(render_dc, &buffer_rect, clear_brush);
        } else {
          FillRect(render_dc, &paint.rcPaint, clear_brush);
        }
        if (owns_clear_brush) {
          DeleteObject(clear_brush);
        }

        const DWORD now = GetTickCount();

        SetBkMode(render_dc, TRANSPARENT);
        SetTextAlign(render_dc, TA_LEFT | TA_TOP | TA_NOUPDATECP);

        HBRUSH bubble_brush = state->bubble_brush;
        HPEN bubble_pen = state->bubble_pen;
        bool owns_bubble_brush = false;
        bool owns_bubble_pen = false;
        if (bubble_brush == nullptr) {
          bubble_brush = CreateSolidBrush(RGB(24, 24, 24));
          owns_bubble_brush = true;
        }
        if (bubble_pen == nullptr) {
          bubble_pen = CreatePen(PS_SOLID, 1, RGB(186, 186, 186));
          owns_bubble_pen = true;
        }
        HGDIOBJ old_brush = SelectObject(render_dc, bubble_brush);
        HGDIOBJ old_pen = SelectObject(render_dc, bubble_pen);

        for (const auto& item : state->items) {
          const double progress = item.duration_ms <= 0
                                      ? 1.0
                                      : ClampDouble(
                                            static_cast<double>(
                                                now - item.start_tick) /
                                                item.duration_ms,
                                            0.0, 1.0);
          const double base_progress =
              item.initial_progress + (1.0 - item.initial_progress) * progress;
          const double eased_progress =
              1.0 - std::pow(1.0 - base_progress, item.speed_factor);
          const double x =
              item.start_x + (item.end_x - item.start_x) * eased_progress;
          const double y = item.row_top;
          const int x_px = static_cast<int>(std::round(x));
          const int y_px = static_cast<int>(std::round(y));

          const int bubble_left = x_px - item.bubble_padding_x;
          const int bubble_top = y_px - item.bubble_padding_y;
          const int bubble_right =
              bubble_left + item.text_width + item.bubble_padding_x * 2;
          const int bubble_bottom =
              bubble_top + item.text_height + item.bubble_padding_y * 2;

          RoundRect(render_dc, bubble_left, bubble_top, bubble_right, bubble_bottom,
                    item.bubble_radius, item.bubble_radius);

          HFONT old_font = nullptr;
          if (item.font != nullptr) {
            old_font = reinterpret_cast<HFONT>(SelectObject(render_dc, item.font));
          }
          SetTextColor(render_dc, RGB(0, 0, 0));
          TextOutW(render_dc, x_px + 1, y_px + 1, item.text.c_str(),
                   std::max(0, item.text_length));

          SetTextColor(render_dc, item.text_color);
          TextOutW(render_dc, x_px, y_px, item.text.c_str(),
                   std::max(0, item.text_length));
          if (old_font != nullptr) {
            SelectObject(render_dc, old_font);
          }
        }

        if (use_back_buffer) {
          // Single blit to present the prepared frame and avoid incremental draw
          // artifacts.
          BitBlt(dc, 0, 0, state->buffer_width, state->buffer_height, render_dc,
                 0, 0, SRCCOPY);
        }

        SelectObject(render_dc, old_pen);
        SelectObject(render_dc, old_brush);
        if (owns_bubble_pen) {
          DeleteObject(bubble_pen);
        }
        if (owns_bubble_brush) {
          DeleteObject(bubble_brush);
        }
      }
      EndPaint(hwnd, &paint);
      return 0;
    }
    case WM_NCDESTROY: {
      auto* state = reinterpret_cast<BarrageOverlayState*>(
          GetWindowLongPtr(hwnd, GWLP_USERDATA));
      if (state != nullptr) {
        if (state->buffer_dc != nullptr) {
          if (state->buffer_old_bitmap != nullptr) {
            SelectObject(state->buffer_dc, state->buffer_old_bitmap);
            state->buffer_old_bitmap = nullptr;
          }
          if (state->buffer_bitmap != nullptr) {
            DeleteObject(state->buffer_bitmap);
            state->buffer_bitmap = nullptr;
          }
          DeleteDC(state->buffer_dc);
          state->buffer_dc = nullptr;
        }
        if (state->clear_brush != nullptr) {
          DeleteObject(state->clear_brush);
          state->clear_brush = nullptr;
        }
        if (state->bubble_pen != nullptr) {
          DeleteObject(state->bubble_pen);
          state->bubble_pen = nullptr;
        }
        if (state->bubble_brush != nullptr) {
          DeleteObject(state->bubble_brush);
          state->bubble_brush = nullptr;
        }
        for (auto& item : state->items) {
          if (item.font != nullptr) {
            DeleteObject(item.font);
            item.font = nullptr;
          }
        }
        delete state;
      }
      SetWindowLongPtr(hwnd, GWLP_USERDATA, 0);
      break;
    }
  }

  return DefWindowProc(hwnd, message, wparam, lparam);
}

std::string FlutterWindow::ParseStringArgument(const flutter::EncodableMap& args,
                                               const char* key,
                                               const std::string& fallback) {
  const auto it = args.find(flutter::EncodableValue(key));
  if (it == args.end()) {
    return fallback;
  }

  if (const auto* string_value = std::get_if<std::string>(&it->second);
      string_value != nullptr) {
    return *string_value;
  }

  if (std::holds_alternative<int32_t>(it->second) ||
      std::holds_alternative<int64_t>(it->second)) {
    return std::to_string(it->second.LongValue());
  }

  if (const auto* double_value = std::get_if<double>(&it->second);
      double_value != nullptr) {
    return std::to_string(*double_value);
  }

  return fallback;
}

int FlutterWindow::ParseIntArgument(const flutter::EncodableMap& args,
                                    const char* key,
                                    int fallback) {
  const auto it = args.find(flutter::EncodableValue(key));
  if (it == args.end()) {
    return fallback;
  }

  if (std::holds_alternative<int32_t>(it->second) ||
      std::holds_alternative<int64_t>(it->second)) {
    return static_cast<int>(it->second.LongValue());
  }

  if (const auto* double_value = std::get_if<double>(&it->second);
      double_value != nullptr) {
    return static_cast<int>(*double_value);
  }

  if (const auto* string_value = std::get_if<std::string>(&it->second);
      string_value != nullptr) {
    try {
      return std::stoi(*string_value);
    } catch (...) {
      return fallback;
    }
  }

  return fallback;
}

double FlutterWindow::ParseDoubleArgument(const flutter::EncodableMap& args,
                                          const char* key,
                                          double fallback) {
  const auto it = args.find(flutter::EncodableValue(key));
  if (it == args.end()) {
    return fallback;
  }

  if (std::holds_alternative<int32_t>(it->second) ||
      std::holds_alternative<int64_t>(it->second)) {
    return static_cast<double>(it->second.LongValue());
  }

  if (const auto* double_value = std::get_if<double>(&it->second);
      double_value != nullptr) {
    return *double_value;
  }

  if (const auto* string_value = std::get_if<std::string>(&it->second);
      string_value != nullptr) {
    try {
      return std::stod(*string_value);
    } catch (...) {
      return fallback;
    }
  }

  return fallback;
}

std::wstring FlutterWindow::Utf16FromUtf8(const std::string& value) {
  if (value.empty()) {
    return L"";
  }

  const int required_size =
      MultiByteToWideChar(CP_UTF8, 0, value.c_str(),
                          static_cast<int>(value.size()), nullptr, 0);
  if (required_size <= 0) {
    return L"";
  }

  std::wstring wide(static_cast<size_t>(required_size), L'\0');
  const int converted =
      MultiByteToWideChar(CP_UTF8, 0, value.c_str(),
                          static_cast<int>(value.size()), &wide[0],
                          required_size);
  if (converted <= 0) {
    return L"";
  }
  return wide;
}

COLORREF FlutterWindow::ParseColor(const std::string& color_string) {
  const std::string normalized = ToLower(color_string);

  try {
    if (normalized.size() == 7 && normalized[0] == '#') {
      const unsigned long value = std::stoul(normalized.substr(1), nullptr, 16);
      const int red = (value >> 16) & 0xff;
      const int green = (value >> 8) & 0xff;
      const int blue = value & 0xff;
      return RGB(red, green, blue);
    }

    if (normalized.rfind("0x", 0) == 0) {
      const unsigned long value = std::stoul(normalized.substr(2), nullptr, 16);
      const int red = (value >> 16) & 0xff;
      const int green = (value >> 8) & 0xff;
      const int blue = value & 0xff;
      return RGB(red, green, blue);
    }
  } catch (...) {
    // Fall through to named color defaults.
  }

  if (normalized == "blue") {
    return RGB(0, 122, 255);
  }
  if (normalized == "green") {
    return RGB(52, 199, 89);
  }
  if (normalized == "yellow") {
    return RGB(255, 204, 0);
  }
  if (normalized == "white") {
    return RGB(255, 255, 255);
  }
  if (normalized == "black") {
    return RGB(0, 0, 0);
  }
  if (normalized == "gray" || normalized == "grey") {
    return RGB(142, 142, 147);
  }
  if (normalized == "orange") {
    return RGB(255, 149, 0);
  }
  if (normalized == "purple") {
    return RGB(175, 82, 222);
  }
  if (normalized == "pink") {
    return RGB(255, 45, 85);
  }
  if (normalized == "cyan") {
    return RGB(90, 200, 250);
  }

  return RGB(255, 59, 48);
}

std::string FlutterWindow::ToLower(std::string value) {
  std::transform(value.begin(), value.end(), value.begin(),
                 [](unsigned char c) {
                   return static_cast<char>(std::tolower(c));
                 });
  return value;
}
