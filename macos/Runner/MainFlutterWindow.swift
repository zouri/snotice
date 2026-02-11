import Cocoa
import CoreGraphics
import FlutterMacOS
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  private var flashToken: Int = 0
  private var flashOverlayWindows: [NSWindow] = []

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    registerScreenChannel(controller: flutterViewController)
    registerFlashChannel(controller: flutterViewController)

    // 支持多窗口插件
    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      RegisterGeneratedPlugins(registry: controller)
      self.registerScreenChannel(controller: controller)
    }

    super.awakeFromNib()
  }

  private func registerFlashChannel(controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "snotice/flash",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(
          FlutterError(
            code: "window_gone",
            message: "Main window is unavailable",
            details: nil
          )
        )
        return
      }

      switch call.method {
      case "triggerFlash":
        let args = call.arguments as? [String: Any] ?? [:]
        let colorString = args["color"] as? String ?? "#FF0000"
        let duration = args["duration"] as? Int ?? 500
        self.triggerNativeFlash(colorString: colorString, durationMs: duration)
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func triggerNativeFlash(colorString: String, durationMs: Int) {
    if !Thread.isMainThread {
      DispatchQueue.main.async { [weak self] in
        self?.triggerNativeFlash(colorString: colorString, durationMs: durationMs)
      }
      return
    }

    flashToken += 1
    let token = flashToken

    if !flashOverlayWindows.isEmpty {
      for existingWindow in flashOverlayWindows {
        existingWindow.orderOut(nil)
      }
      flashOverlayWindows.removeAll()
    }

    let screens = NSScreen.screens
    if screens.isEmpty {
      return
    }

    let flashColor = parseColor(colorString).withAlphaComponent(1.0)
    let shieldingLevel = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
    var windows: [NSWindow] = []

    for screen in screens {
      let frame = screen.frame
      let window = NSWindow(
        contentRect: frame,
        styleMask: [.borderless],
        backing: .buffered,
        defer: false
      )

      window.level = shieldingLevel
      window.isOpaque = false
      window.isReleasedWhenClosed = false
      window.backgroundColor = flashColor
      window.alphaValue = 0
      window.hasShadow = false
      window.ignoresMouseEvents = true
      window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
      window.setFrame(frame, display: true)
      window.orderFrontRegardless()
      windows.append(window)
    }

    flashOverlayWindows = windows

    let fadeInMs = max(80, min(200, durationMs / 3))
    let holdMs = max(0, durationMs - fadeInMs)
    let fadeOutMs = max(80, min(220, durationMs / 2))

    NSAnimationContext.runAnimationGroup { context in
      context.duration = Double(fadeInMs) / 1000.0
      for window in windows {
        window.animator().alphaValue = 0.8
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(fadeInMs + holdMs)) { [weak self] in
      guard let self else {
        return
      }
      guard token == self.flashToken else {
        return
      }

      NSAnimationContext.runAnimationGroup(
        {
          context in
          context.duration = Double(fadeOutMs) / 1000.0
          for window in windows {
            window.animator().alphaValue = 0
          }
        },
        completionHandler: { [weak self] in
          guard let self else {
            return
          }
          guard token == self.flashToken else {
            return
          }
          for window in windows {
            window.orderOut(nil)
          }
          self.flashOverlayWindows.removeAll()
        }
      )
    }
  }

  private func parseColor(_ value: String) -> NSColor {
    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    if normalized.hasPrefix("#") {
      let hex = String(normalized.dropFirst())
      if hex.count == 6, let intValue = Int(hex, radix: 16) {
        let r = CGFloat((intValue >> 16) & 0xFF) / 255.0
        let g = CGFloat((intValue >> 8) & 0xFF) / 255.0
        let b = CGFloat(intValue & 0xFF) / 255.0
        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
      }
    }

    switch normalized {
    case "white":
      return .white
    case "black":
      return .black
    case "blue":
      return .blue
    case "green":
      return .green
    case "yellow":
      return .yellow
    case "gray", "grey":
      return .gray
    case "orange":
      return .orange
    case "purple":
      return .purple
    case "pink":
      return .systemPink
    case "cyan":
      return .cyan
    default:
      return .red
    }
  }

  private func registerScreenChannel(controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "snotice/screen",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getMainScreenFrame":
        let screen = controller.view.window?.screen ?? NSScreen.main
        guard let frame = screen?.frame else {
          result(
            FlutterError(
              code: "no_screen",
              message: "Unable to access macOS screen frame",
              details: nil
            )
          )
          return
        }

        result([
          "width": frame.size.width,
          "height": frame.size.height,
          "x": frame.origin.x,
          "y": frame.origin.y
        ])
      case "configureOverlayWindow":
        guard let window = controller.view.window else {
          result(
            FlutterError(
              code: "no_window",
              message: "Unable to access overlay window",
              details: nil
            )
          )
          return
        }

        let screen = window.screen ?? NSScreen.main
        guard let frame = screen?.frame else {
          result(
            FlutterError(
              code: "no_screen",
              message: "Unable to access macOS screen frame",
              details: nil
            )
          )
          return
        }

        window.level = .screenSaver
        window.collectionBehavior.insert(.canJoinAllSpaces)
        window.collectionBehavior.insert(.fullScreenAuxiliary)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.setFrame(frame, display: true)
        window.orderFrontRegardless()

        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
