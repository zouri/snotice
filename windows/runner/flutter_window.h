#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/encodable_value.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>

#include <memory>
#include <random>
#include <string>
#include <vector>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  enum class OverlayWindowKind {
    kFull,
    kEdge,
    kBarrage,
  };

  struct FlashOverlayWindow {
    HWND hwnd = nullptr;
    OverlayWindowKind kind = OverlayWindowKind::kFull;
  };

  enum class NativeOverlayMode {
    kNone,
    kEdge,
    kBarrage,
  };

  static constexpr UINT_PTR kFlashOverlayCloseTimerId = 0x534e4f54;
  static constexpr UINT_PTR kFlashOverlayAnimationTimerId = 0x534e4f41;
  static constexpr wchar_t kFlashOverlayClassName[] =
      L"SNOTICE_NATIVE_FLASH_OVERLAY";
  static constexpr wchar_t kEdgeOverlayClassName[] =
      L"SNOTICE_NATIVE_EDGE_OVERLAY";
  static constexpr wchar_t kBarrageOverlayClassName[] =
      L"SNOTICE_NATIVE_BARRAGE_OVERLAY";

  void RegisterFlashChannel();
  void HandleFlashMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  bool TriggerNativeFlash(const flutter::EncodableMap& args);
  bool TriggerNativeFull(const flutter::EncodableMap& args);
  bool TriggerNativeEdge(const flutter::EncodableMap& args);
  bool TriggerNativeBarrage(const flutter::EncodableMap& args);
  static bool IsEdgeEffect(const std::string& effect);
  void TickNativeAnimation();
  void ClearFlashOverlayWindows();
  void CancelTimers();
  void StartAnimationTimer();
  void EnsureFlashOverlayClassRegistered();
  void EnsureEdgeOverlayClassRegistered();
  void EnsureBarrageOverlayClassRegistered();
  void CreateFlashOverlayForMonitor(const RECT& bounds, COLORREF color);
  void CreateEdgeOverlayForMonitor(const RECT& bounds,
                                   COLORREF color,
                                   int line_width);
  void CreateBarrageOverlayForMonitor(const RECT& bounds,
                                      const std::wstring& text,
                                      COLORREF color,
                                      int duration_ms,
                                      double speed,
                                      int font_size,
                                      const std::string& lane,
                                      int repeat_count);
  static BOOL CALLBACK EnumDisplayMonitorsProc(HMONITOR monitor,
                                                HDC hdc,
                                                LPRECT rect,
                                                LPARAM data);
  static BOOL CALLBACK EnumDisplayMonitorsEdgeProc(HMONITOR monitor,
                                                    HDC hdc,
                                                    LPRECT rect,
                                                    LPARAM data);
  static BOOL CALLBACK EnumDisplayMonitorsBarrageProc(HMONITOR monitor,
                                                       HDC hdc,
                                                       LPRECT rect,
                                                       LPARAM data);
  static LRESULT CALLBACK FlashOverlayWndProc(HWND hwnd,
                                              UINT message,
                                              WPARAM wparam,
                                              LPARAM lparam) noexcept;
  static LRESULT CALLBACK EdgeOverlayWndProc(HWND hwnd,
                                             UINT message,
                                             WPARAM wparam,
                                             LPARAM lparam) noexcept;
  static LRESULT CALLBACK BarrageOverlayWndProc(HWND hwnd,
                                                UINT message,
                                                WPARAM wparam,
                                                LPARAM lparam) noexcept;
  static std::string ParseStringArgument(const flutter::EncodableMap& args,
                                         const char* key,
                                         const std::string& fallback);
  static int ParseIntArgument(const flutter::EncodableMap& args,
                              const char* key,
                              int fallback);
  static double ParseDoubleArgument(const flutter::EncodableMap& args,
                                    const char* key,
                                    double fallback);
  static std::wstring Utf16FromUtf8(const std::string& value);
  static COLORREF ParseColor(const std::string& color_string);
  static std::string ToLower(std::string value);

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      flash_channel_;
  std::vector<FlashOverlayWindow> flash_overlay_windows_;
  NativeOverlayMode native_overlay_mode_ = NativeOverlayMode::kNone;
  DWORD native_overlay_start_tick_ = 0;
  int native_overlay_total_duration_ms_ = 0;
  int edge_cycle_duration_ms_ = 500;
  BYTE edge_min_alpha_ = 30;
  BYTE edge_max_alpha_ = 220;
  std::mt19937 random_engine_;
  bool flash_overlay_class_registered_ = false;
  bool edge_overlay_class_registered_ = false;
  bool barrage_overlay_class_registered_ = false;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
