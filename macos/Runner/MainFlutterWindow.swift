import Cocoa
import CoreGraphics
import FlutterMacOS
import audioplayers_darwin
import flutter_local_notifications
import screen_retriever_macos
import shared_preferences_foundation
import system_tray
import window_manager

class MainFlutterWindow: NSWindow {
  private var flashToken: Int = 0
  private var flashOverlayWindows: [NSPanel] = []

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    registerMacOSPlugins(registry: flutterViewController)
    registerFlashChannel(controller: flutterViewController)

    super.awakeFromNib()
  }

  private func registerMacOSPlugins(registry: FlutterPluginRegistry) {
    AudioplayersDarwinPlugin.register(
      with: registry.registrar(forPlugin: "AudioplayersDarwinPlugin"))
    FlutterLocalNotificationsPlugin.register(
      with: registry.registrar(forPlugin: "FlutterLocalNotificationsPlugin"))
    ScreenRetrieverMacosPlugin.register(
      with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
    SharedPreferencesPlugin.register(
      with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
    SystemTrayPlugin.register(with: registry.registrar(forPlugin: "SystemTrayPlugin"))
    WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
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
        let duration = self.parseInt(args["duration"], fallback: 500)
        let effect = (args["effect"] as? String ?? "full").lowercased()

        if effect == "edge" {
          let width = self.parseDouble(args["width"], fallback: 14.0)
          let opacity = self.parseDouble(args["opacity"], fallback: 0.92)
          let repeatCount = max(1, self.parseInt(args["repeat"], fallback: 2))
          self.triggerEdgeLighting(
            colorString: colorString,
            durationMs: duration,
            lineWidth: width,
            opacity: opacity,
            repeatCount: repeatCount
          )
        } else {
          self.triggerNativeFlash(colorString: colorString, durationMs: duration)
        }

        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func parseInt(_ value: Any?, fallback: Int) -> Int {
    if let intValue = value as? Int {
      return intValue
    }
    if let numberValue = value as? NSNumber {
      return numberValue.intValue
    }
    if let stringValue = value as? String, let intValue = Int(stringValue) {
      return intValue
    }
    return fallback
  }

  private func parseDouble(_ value: Any?, fallback: Double) -> Double {
    if let doubleValue = value as? Double {
      return doubleValue
    }
    if let floatValue = value as? Float {
      return Double(floatValue)
    }
    if let intValue = value as? Int {
      return Double(intValue)
    }
    if let numberValue = value as? NSNumber {
      return numberValue.doubleValue
    }
    if let stringValue = value as? String, let doubleValue = Double(stringValue) {
      return doubleValue
    }
    return fallback
  }

  private func clearOverlayWindows() {
    guard !flashOverlayWindows.isEmpty else {
      return
    }

    for window in flashOverlayWindows {
      window.orderOut(nil)
    }
    flashOverlayWindows.removeAll()
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

    clearOverlayWindows()

    let screens = NSScreen.screens
    if screens.isEmpty {
      return
    }

    let flashColor = parseColor(colorString).withAlphaComponent(1.0)
    // Use screenSaver level to ensure the overlay appears on all spaces and covers the menu bar
    let overlayLevel = NSWindow.Level.screenSaver
    var windows: [NSPanel] = []

    for screen in screens {
      let frame = screen.frame
      let window = NSPanel(
        contentRect: frame,
        styleMask: [.borderless, .nonactivatingPanel],
        backing: .buffered,
        defer: false
      )

      window.level = overlayLevel
      window.isOpaque = false
      window.isReleasedWhenClosed = false
      window.backgroundColor = flashColor
      window.alphaValue = 0
      window.hasShadow = false
      window.ignoresMouseEvents = true
      // Use canJoinAllSpaces to follow the user across virtual desktops (Spaces)
      // Avoid fullScreenPrimary as it may restrict the window to the primary space only
      window.collectionBehavior = [
        .canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle,
      ]
      window.setFrame(frame, display: false)
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

    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(fadeInMs + holdMs)) {
      [weak self] in
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
          self.clearOverlayWindows()
        }
      )
    }
  }

  private func triggerEdgeLighting(
    colorString: String,
    durationMs: Int,
    lineWidth: Double,
    opacity: Double,
    repeatCount: Int
  ) {
    if !Thread.isMainThread {
      DispatchQueue.main.async { [weak self] in
        self?.triggerEdgeLighting(
          colorString: colorString,
          durationMs: durationMs,
          lineWidth: lineWidth,
          opacity: opacity,
          repeatCount: repeatCount
        )
      }
      return
    }

    flashToken += 1
    let token = flashToken
    clearOverlayWindows()

    let screens = NSScreen.screens
    if screens.isEmpty {
      return
    }

    let edgeColor = parseColor(colorString)
    let clampedOpacity = max(0.1, min(1.0, opacity))
    let clampedLineWidth = max(2.0, min(48.0, lineWidth))
    let safeRepeat = max(1, repeatCount)
    let cycleSeconds = max(0.5, Double(durationMs) / 1000.0)
    let totalSeconds = cycleSeconds * Double(safeRepeat)
    let overlayLevel = NSWindow.Level.screenSaver

    var windows: [NSPanel] = []

    for screen in screens {
      let frame = screen.frame
      let window = NSPanel(
        contentRect: frame,
        styleMask: [.borderless, .nonactivatingPanel],
        backing: .buffered,
        defer: false
      )

      window.level = overlayLevel
      window.isOpaque = false
      window.isReleasedWhenClosed = false
      window.backgroundColor = .clear
      window.alphaValue = 1
      window.hasShadow = false
      window.ignoresMouseEvents = true
      window.collectionBehavior = [
        .canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle,
      ]
      window.setFrame(frame, display: false)

      let container = NSView(frame: NSRect(origin: .zero, size: frame.size))
      container.wantsLayer = true
      container.layer?.backgroundColor = NSColor.clear.cgColor

      if let rootLayer = container.layer {
        let edgeLayer = buildEdgeLayer(
          frame: container.bounds,
          color: edgeColor,
          lineWidth: CGFloat(clampedLineWidth),
          opacity: CGFloat(clampedOpacity),
          cycleSeconds: cycleSeconds,
          repeatCount: safeRepeat
        )
        rootLayer.addSublayer(edgeLayer)
      }

      window.contentView = container
      window.orderFrontRegardless()
      windows.append(window)
    }

    flashOverlayWindows = windows

    DispatchQueue.main.asyncAfter(deadline: .now() + totalSeconds + 0.05) {
      [weak self] in
      guard let self else {
        return
      }
      guard token == self.flashToken else {
        return
      }

      NSAnimationContext.runAnimationGroup(
        { context in
          context.duration = 0.12
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
          self.clearOverlayWindows()
        }
      )
    }
  }

  private func buildEdgeLayer(
    frame: CGRect,
    color: NSColor,
    lineWidth: CGFloat,
    opacity: CGFloat,
    cycleSeconds: CFTimeInterval,
    repeatCount: Int
  ) -> CAShapeLayer {
    let inset = max(4.0, lineWidth / 2.0 + 2.0)
    let roundedRect = frame.insetBy(dx: inset, dy: inset)
    let cornerRadius = max(16.0, lineWidth * 2.4)
    let path = CGPath(
      roundedRect: roundedRect,
      cornerWidth: cornerRadius,
      cornerHeight: cornerRadius,
      transform: nil
    )

    let edgeLayer = CAShapeLayer()
    edgeLayer.frame = frame
    edgeLayer.path = path
    edgeLayer.fillColor = NSColor.clear.cgColor
    edgeLayer.strokeColor = color.withAlphaComponent(opacity).cgColor
    edgeLayer.lineWidth = lineWidth
    edgeLayer.lineCap = .round
    edgeLayer.shadowColor = color.cgColor
    edgeLayer.shadowOffset = .zero
    edgeLayer.shadowRadius = max(6.0, lineWidth * 1.8)
    edgeLayer.shadowOpacity = Float(min(1.0, opacity + 0.15))
    edgeLayer.opacity = Float(opacity)
    edgeLayer.strokeStart = 0
    edgeLayer.strokeEnd = 0.16

    let strokeStart = CABasicAnimation(keyPath: "strokeStart")
    strokeStart.fromValue = -0.2
    strokeStart.toValue = 1.0

    let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
    strokeEnd.fromValue = 0.0
    strokeEnd.toValue = 1.2

    let sweep = CAAnimationGroup()
    sweep.animations = [strokeStart, strokeEnd]
    sweep.duration = cycleSeconds
    sweep.repeatCount = Float(max(1, repeatCount))
    sweep.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    sweep.fillMode = .forwards
    sweep.isRemovedOnCompletion = false
    edgeLayer.add(sweep, forKey: "edgeSweep")

    let pulse = CABasicAnimation(keyPath: "opacity")
    pulse.fromValue = max(0.35, opacity * 0.5)
    pulse.toValue = min(1.0, opacity)
    pulse.autoreverses = true
    pulse.duration = max(0.2, cycleSeconds / 2.0)
    pulse.repeatCount = Float(max(1, repeatCount) * 2)
    pulse.fillMode = .forwards
    pulse.isRemovedOnCompletion = false
    edgeLayer.add(pulse, forKey: "edgePulse")

    return edgeLayer
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
}
