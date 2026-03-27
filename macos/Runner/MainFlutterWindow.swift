import Cocoa
import CoreGraphics
import FlutterMacOS
import ServiceManagement
import desktop_multi_window
import flutter_local_notifications
import screen_retriever_macos
import shared_preferences_foundation
import system_tray
import window_manager

class MainFlutterWindow: NSWindow {
  private var flashToken: Int = 0
  private var flashOverlayWindows: [NSPanel] = []
  private var activeOverlayMode: OverlayMode = .none
  private var barrageOverlayDeadline: Date?
  private var barrageCloseWorkItem: DispatchWorkItem?

  private enum OverlayMode {
    case none
    case flash
    case edge
    case barrage
  }

  private enum BarrageLane {
    case top
    case middle
    case bottom

    static func from(rawValue: String?) -> BarrageLane {
      switch rawValue?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
      case "middle":
        return .middle
      case "bottom":
        return .bottom
      default:
        return .top
      }
    }
  }

  private enum EdgeLightingStyle {
    case sweep
    case pulse
    case dual
    case dash
    case corner
    case rainbow

    static func from(effect: String) -> EdgeLightingStyle? {
      switch effect {
      case "edge", "edge_sweep", "sweep":
        return .sweep
      case "edge_pulse", "pulse":
        return .pulse
      case "edge_dual", "dual":
        return .dual
      case "edge_dash", "dash":
        return .dash
      case "edge_corner", "corner":
        return .corner
      case "edge_rainbow", "rainbow":
        return .rainbow
      default:
        return nil
      }
    }
  }

  private struct EdgeGeometry {
    let frame: CGRect
    let path: CGPath
    let roundedRect: CGRect
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    registerMacOSPlugins(registry: flutterViewController)
    registerStartupChannel(controller: flutterViewController)
    registerFlashChannel(controller: flutterViewController)

    super.awakeFromNib()
  }

  private func registerMacOSPlugins(registry: FlutterPluginRegistry) {
    FlutterMultiWindowPlugin.register(
      with: registry.registrar(forPlugin: "FlutterMultiWindowPlugin"))
    FlutterLocalNotificationsPlugin.register(
      with: registry.registrar(forPlugin: "FlutterLocalNotificationsPlugin"))
    ScreenRetrieverMacosPlugin.register(
      with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
    SharedPreferencesPlugin.register(
      with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
    SystemTrayPlugin.register(with: registry.registrar(forPlugin: "SystemTrayPlugin"))
    WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
  }

  private func registerStartupChannel(controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "snotice/startup",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isEnabled":
        if #available(macOS 13.0, *) {
          result(SMAppService.mainApp.status == .enabled)
        } else {
          result(
            FlutterError(
              code: "unsupported",
              message: "Auto-launch on login requires macOS 13.0 or later.",
              details: nil
            )
          )
        }
      case "setEnabled":
        guard
          let arguments = call.arguments as? [String: Any],
          let enabled = arguments["enabled"] as? Bool
        else {
          result(
            FlutterError(
              code: "bad_args",
              message: "Missing required boolean argument: enabled",
              details: nil
            )
          )
          return
        }

        if #available(macOS 13.0, *) {
          do {
            if enabled {
              try SMAppService.mainApp.register()
              if SMAppService.mainApp.status == .requiresApproval {
                result(
                  FlutterError(
                    code: "requires_approval",
                    message: "Please enable SNotice in System Settings > General > Login Items.",
                    details: nil
                  )
                )
                return
              }
            } else {
              try SMAppService.mainApp.unregister()
            }
            result(nil)
          } catch {
            result(
              FlutterError(
                code: "startup_toggle_failed",
                message: "Failed to update login item status.",
                details: "\(error)"
              )
            )
          }
        } else {
          result(
            FlutterError(
              code: "unsupported",
              message: "Auto-launch on login requires macOS 13.0 or later.",
              details: nil
            )
          )
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
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

        if effect == "barrage" {
          let text = self.parseString(args["text"], fallback: "SNotice")
          let speed = self.parseDouble(args["speed"], fallback: 120.0)
          let fontSize = self.parseDouble(args["fontSize"], fallback: 28.0)
          let lane = BarrageLane.from(rawValue: args["lane"] as? String)
          let repeatCount = max(1, min(8, self.parseInt(args["repeat"], fallback: 1)))
          self.triggerNativeBarrage(
            colorString: colorString,
            text: text,
            durationMs: duration,
            speed: speed,
            fontSize: fontSize,
            lane: lane,
            repeatCount: repeatCount
          )
        } else if let style = EdgeLightingStyle.from(effect: effect) {
          let width = self.parseDouble(args["width"], fallback: 14.0)
          let opacity = self.parseDouble(args["opacity"], fallback: 0.92)
          let repeatCount = max(1, self.parseInt(args["repeat"], fallback: 2))
          self.triggerEdgeLighting(
            style: style,
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

  private func parseString(_ value: Any?, fallback: String) -> String {
    if let stringValue = value as? String {
      return stringValue
    }
    if let numberValue = value as? NSNumber {
      return numberValue.stringValue
    }
    return fallback
  }

  private func clearOverlayWindows() {
    barrageCloseWorkItem?.cancel()
    barrageCloseWorkItem = nil
    barrageOverlayDeadline = nil
    activeOverlayMode = .none

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
    activeOverlayMode = .flash

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

  private func triggerNativeBarrage(
    colorString: String,
    text: String,
    durationMs: Int,
    speed: Double,
    fontSize: Double,
    lane: BarrageLane,
    repeatCount: Int
  ) {
    if !Thread.isMainThread {
      DispatchQueue.main.async { [weak self] in
        self?.triggerNativeBarrage(
          colorString: colorString,
          text: text,
          durationMs: durationMs,
          speed: speed,
          fontSize: fontSize,
          lane: lane,
          repeatCount: repeatCount
        )
      }
      return
    }

    let shouldReuseActiveBarrageWindow =
      activeOverlayMode == .barrage && !flashOverlayWindows.isEmpty
    if !shouldReuseActiveBarrageWindow {
      flashToken += 1
      clearOverlayWindows()
      activeOverlayMode = .barrage
    }
    let token = flashToken

    let clampedSpeed = max(40.0, min(1200.0, speed))
    let clampedFontSize = max(12.0, min(96.0, fontSize))
    let safeRepeat = max(1, min(8, repeatCount))
    let displayText = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      ? "SNotice"
      : text
    let textColor = parseColor(colorString)
    let windows: [NSPanel]
    if shouldReuseActiveBarrageWindow {
      windows = flashOverlayWindows
    } else {
      let screens = NSScreen.screens
      if screens.isEmpty {
        return
      }
      windows = createBarrageWindows(for: screens)
      flashOverlayWindows = windows
    }

    var totalSeconds: Double = 0.0
    for window in windows {
      guard let container = window.contentView else {
        continue
      }
      totalSeconds = max(
        totalSeconds,
        appendBarrageItems(
          in: container,
          containerSize: container.bounds.size,
          text: displayText,
          textColor: textColor,
          durationMs: durationMs,
          speed: clampedSpeed,
          fontSize: clampedFontSize,
          lane: lane,
          repeatCount: safeRepeat
        )
      )
    }

    let now = Date()
    let requestedCloseTime = now.addingTimeInterval(totalSeconds + 0.08)
    if let existingDeadline = barrageOverlayDeadline {
      barrageOverlayDeadline = max(existingDeadline, requestedCloseTime)
    } else {
      barrageOverlayDeadline = requestedCloseTime
    }

    guard let closeDeadline = barrageOverlayDeadline else {
      return
    }
    let closeDelay = max(0, closeDeadline.timeIntervalSince(now))
    scheduleBarrageClose(after: closeDelay, token: token)
  }

  private func createBarrageWindows(for screens: [NSScreen]) -> [NSPanel] {
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
      window.contentView = container
      window.orderFrontRegardless()
      windows.append(window)
    }
    return windows
  }

  private func appendBarrageItems(
    in container: NSView,
    containerSize: CGSize,
    text: String,
    textColor: NSColor,
    durationMs: Int,
    speed: Double,
    fontSize: Double,
    lane: BarrageLane,
    repeatCount: Int
  ) -> Double {
    let font = NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .bold)
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.72)
    shadow.shadowOffset = NSSize(width: 0, height: -1)
    shadow.shadowBlurRadius = 8
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: textColor,
      .shadow: shadow,
    ]

    let sampleLabel = NSTextField(labelWithString: "")
    sampleLabel.attributedStringValue = NSAttributedString(
      string: text,
      attributes: attributes
    )
    sampleLabel.sizeToFit()

    let textWidth = max(40.0, sampleLabel.fittingSize.width)
    let textHeight = max(20.0, sampleLabel.fittingSize.height)
    let startX = containerSize.width + 36.0
    let endXBase = -textWidth - 60.0
    let baseY = barrageOriginY(
      lane: lane,
      containerHeight: containerSize.height,
      textHeight: textHeight
    )
    let rowSpacing = max(36.0, min(120.0, textHeight + 12.0))
    let rowTops = barrageRowPositions(
      lane: lane,
      count: repeatCount,
      baseY: baseY,
      rowSpacing: rowSpacing,
      containerHeight: containerSize.height,
      textHeight: textHeight
    )

    let bubbleInsetX = 14.0
    let bubbleInsetY = 8.0
    var totalSeconds: Double = 0.0
    for index in 0..<repeatCount {
      let rowY = rowTops[index]
      let spawnOffset = CGFloat.random(
        in: (-containerSize.width * 0.18)...(containerSize.width * 0.35))
      let endExtra = CGFloat.random(in: 0...(containerSize.width * 0.2))
      let currentStartX = startX + spawnOffset
      let currentEndX = endXBase - endExtra
      let initialProgress = CGFloat.random(in: 0.06...0.42)
      let speedFactor = Double.random(in: 0.82...1.2)
      let adjustedSpeed = speed * speedFactor
      let startXNow = currentStartX + (currentEndX - currentStartX) * initialProgress
      let remainingDistance = max(1.0, startXNow - currentEndX)
      let remainingTravelSeconds = remainingDistance / adjustedSpeed
      let requestedSeconds = max(0.6, Double(durationMs) / 1000.0)
      let animationSeconds = max(
        requestedSeconds * (1.0 - Double(initialProgress) * 0.55),
        remainingTravelSeconds
      )
      totalSeconds = max(totalSeconds, animationSeconds)

      let bubble = NSView(
        frame: NSRect(
          x: startXNow - bubbleInsetX,
          y: rowY - bubbleInsetY,
          width: textWidth + bubbleInsetX * 2.0,
          height: textHeight + bubbleInsetY * 2.0
        )
      )
      bubble.wantsLayer = true
      bubble.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.22).cgColor
      bubble.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
      bubble.layer?.borderWidth = 1
      bubble.layer?.cornerRadius = 12

      let label = NSTextField(labelWithString: "")
      label.attributedStringValue = NSAttributedString(
        string: text,
        attributes: attributes
      )
      label.backgroundColor = .clear
      label.drawsBackground = false
      label.isBezeled = false
      label.isEditable = false
      label.isSelectable = false
      label.lineBreakMode = .byClipping
      label.maximumNumberOfLines = 1
      label.frame = NSRect(
        x: startXNow,
        y: rowY,
        width: textWidth,
        height: textHeight
      )

      container.addSubview(bubble)
      container.addSubview(label)

      NSAnimationContext.runAnimationGroup { context in
        context.duration = animationSeconds
        context.timingFunction = CAMediaTimingFunction(name: .linear)
        label.animator().setFrameOrigin(NSPoint(x: currentEndX, y: rowY))
        bubble.animator().setFrameOrigin(
          NSPoint(x: currentEndX - bubbleInsetX, y: rowY - bubbleInsetY)
        )
      }
    }
    return totalSeconds
  }

  private func scheduleBarrageClose(after delay: TimeInterval, token: Int) {
    barrageCloseWorkItem?.cancel()
    let workItem = DispatchWorkItem { [weak self] in
      guard let self else {
        return
      }
      guard token == self.flashToken else {
        return
      }
      guard self.activeOverlayMode == .barrage else {
        return
      }
      let windows = self.flashOverlayWindows
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
          guard self.activeOverlayMode == .barrage else {
            return
          }
          self.clearOverlayWindows()
        }
      )
    }
    barrageCloseWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
  }

  private func barrageOriginY(
    lane: BarrageLane,
    containerHeight: CGFloat,
    textHeight: CGFloat
  ) -> CGFloat {
    switch lane {
    case .top:
      let topInset = max(48.0, textHeight * 1.4)
      return max(0, containerHeight - topInset - textHeight)
    case .middle:
      return max(0, (containerHeight - textHeight) / 2.0)
    case .bottom:
      let bottomInset = max(52.0, textHeight * 1.2)
      return max(0, bottomInset)
    }
  }

  private func barrageRowY(
    lane: BarrageLane,
    index: Int,
    baseY: CGFloat,
    rowSpacing: CGFloat,
    containerHeight: CGFloat,
    textHeight: CGFloat
  ) -> CGFloat {
    let rawY: CGFloat
    switch lane {
    case .top:
      rawY = baseY - CGFloat(index) * rowSpacing
    case .middle:
      rawY = baseY + middleSignedStep(index) * rowSpacing
    case .bottom:
      rawY = baseY + CGFloat(index) * rowSpacing
    }
    return clampBarrageY(rawY, containerHeight: containerHeight, textHeight: textHeight)
  }

  private func barrageRowPositions(
    lane: BarrageLane,
    count: Int,
    baseY: CGFloat,
    rowSpacing: CGFloat,
    containerHeight: CGFloat,
    textHeight: CGFloat
  ) -> [CGFloat] {
    var rows: [CGFloat] = []
    rows.reserveCapacity(max(1, count))
    for index in 0..<max(1, count) {
      let baseRowY = barrageRowY(
        lane: lane,
        index: index,
        baseY: baseY,
        rowSpacing: rowSpacing,
        containerHeight: containerHeight,
        textHeight: textHeight
      )
      let jitter = CGFloat.random(in: (-rowSpacing * 0.35)...(rowSpacing * 0.35))
      rows.append(
        clampBarrageY(
          baseRowY + jitter,
          containerHeight: containerHeight,
          textHeight: textHeight
        )
      )
    }
    return rows.shuffled()
  }

  private func middleSignedStep(_ index: Int) -> CGFloat {
    if index == 0 {
      return 0
    }
    let level = CGFloat((index + 1) / 2)
    return index % 2 == 1 ? level : -level
  }

  private func clampBarrageY(
    _ y: CGFloat,
    containerHeight: CGFloat,
    textHeight: CGFloat
  ) -> CGFloat {
    let minY: CGFloat = 0
    let maxY = max(0, containerHeight - textHeight)
    return min(max(y, minY), maxY)
  }

  private func triggerEdgeLighting(
    style: EdgeLightingStyle,
    colorString: String,
    durationMs: Int,
    lineWidth: Double,
    opacity: Double,
    repeatCount: Int
  ) {
    if !Thread.isMainThread {
      DispatchQueue.main.async { [weak self] in
        self?.triggerEdgeLighting(
          style: style,
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
    activeOverlayMode = .edge

    let screens = NSScreen.screens
    if screens.isEmpty {
      return
    }

    let edgeColor = parseColor(colorString)
    let clampedOpacity = max(0.1, min(1.0, opacity))
    let clampedLineWidth = max(2.0, min(48.0, lineWidth))
    let safeRepeat = max(1, repeatCount)
    let baseCycleSeconds = max(0.5, Double(durationMs) / 1000.0)
    let cycleSeconds: CFTimeInterval
    switch style {
    case .corner:
      cycleSeconds = max(0.4, baseCycleSeconds * 0.8)
    case .rainbow:
      cycleSeconds = max(0.65, baseCycleSeconds)
    default:
      cycleSeconds = baseCycleSeconds
    }
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
        let geometry = buildEdgeGeometry(
          frame: container.bounds,
          lineWidth: CGFloat(clampedLineWidth)
        )
        applyEdgeStyle(
          style: style,
          rootLayer: rootLayer,
          geometry: geometry,
          color: edgeColor,
          opacity: CGFloat(clampedOpacity),
          cycleSeconds: cycleSeconds,
          repeatCount: safeRepeat
        )
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

  private func buildEdgeGeometry(
    frame: CGRect,
    lineWidth: CGFloat
  ) -> EdgeGeometry {
    let inset = max(4.0, lineWidth / 2.0 + 2.0)
    let roundedRect = frame.insetBy(dx: inset, dy: inset)
    let cornerRadius = max(16.0, lineWidth * 2.4)
    let path = CGPath(
      roundedRect: roundedRect,
      cornerWidth: cornerRadius,
      cornerHeight: cornerRadius,
      transform: nil
    )
    return EdgeGeometry(
      frame: frame,
      path: path,
      roundedRect: roundedRect,
      cornerRadius: cornerRadius,
      lineWidth: lineWidth
    )
  }

  private func applyEdgeStyle(
    style: EdgeLightingStyle,
    rootLayer: CALayer,
    geometry: EdgeGeometry,
    color: NSColor,
    opacity: CGFloat,
    cycleSeconds: CFTimeInterval,
    repeatCount: Int
  ) {
    switch style {
    case .sweep:
      rootLayer.addSublayer(
        buildSweepLayer(
          geometry: geometry,
          color: color,
          opacity: opacity,
          cycleSeconds: cycleSeconds,
          repeatCount: repeatCount,
          reverse: false
        )
      )
    case .pulse:
      rootLayer.addSublayer(
        buildPulseLayer(
          geometry: geometry,
          color: color,
          opacity: opacity,
          cycleSeconds: cycleSeconds,
          repeatCount: repeatCount
        )
      )
    case .dual:
      let primary = buildSweepLayer(
        geometry: geometry,
        color: color,
        opacity: opacity,
        cycleSeconds: cycleSeconds,
        repeatCount: repeatCount,
        reverse: false
      )
      let secondaryColor = color.blended(withFraction: 0.35, of: .white) ?? color
      let secondary = buildSweepLayer(
        geometry: geometry,
        color: secondaryColor,
        opacity: max(0.2, opacity * 0.86),
        cycleSeconds: cycleSeconds,
        repeatCount: repeatCount,
        reverse: true
      )
      secondary.strokeStart = 0.5
      secondary.strokeEnd = 0.68
      rootLayer.addSublayer(primary)
      rootLayer.addSublayer(secondary)
    case .dash:
      rootLayer.addSublayer(
        buildDashLayer(
          geometry: geometry,
          color: color,
          opacity: opacity,
          cycleSeconds: cycleSeconds,
          repeatCount: repeatCount
        )
      )
    case .corner:
      rootLayer.addSublayer(
        buildCornerLayer(
          geometry: geometry,
          color: color,
          opacity: opacity,
          cycleSeconds: cycleSeconds,
          repeatCount: repeatCount
        )
      )
    case .rainbow:
      rootLayer.addSublayer(
        buildRainbowLayerGroup(
          geometry: geometry,
          baseColor: color,
          opacity: opacity,
          cycleSeconds: cycleSeconds,
          repeatCount: repeatCount
        )
      )
    }
  }

  private func buildSweepLayer(
    geometry: EdgeGeometry,
    color: NSColor,
    opacity: CGFloat,
    cycleSeconds: CFTimeInterval,
    repeatCount: Int,
    reverse: Bool
  ) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.frame = geometry.frame
    layer.path = geometry.path
    layer.fillColor = NSColor.clear.cgColor
    layer.strokeColor = color.withAlphaComponent(opacity).cgColor
    layer.lineWidth = geometry.lineWidth
    layer.lineCap = .round
    layer.shadowColor = color.cgColor
    layer.shadowOffset = .zero
    layer.shadowRadius = max(6.0, geometry.lineWidth * 1.7)
    layer.shadowOpacity = Float(min(1.0, opacity + 0.12))
    layer.opacity = Float(opacity)
    layer.strokeStart = reverse ? 0.5 : 0.0
    layer.strokeEnd = reverse ? 0.68 : 0.18

    let strokeStart = CABasicAnimation(keyPath: "strokeStart")
    let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")

    if reverse {
      strokeStart.fromValue = 1.2
      strokeStart.toValue = 0.0
      strokeEnd.fromValue = 1.4
      strokeEnd.toValue = 0.2
    } else {
      strokeStart.fromValue = -0.2
      strokeStart.toValue = 1.0
      strokeEnd.fromValue = 0.0
      strokeEnd.toValue = 1.2
    }

    let sweep = CAAnimationGroup()
    sweep.animations = [strokeStart, strokeEnd]
    sweep.duration = cycleSeconds
    sweep.repeatCount = Float(max(1, repeatCount))
    sweep.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    sweep.fillMode = .forwards
    sweep.isRemovedOnCompletion = false
    layer.add(sweep, forKey: "edgeSweep")

    addOpacityPulseAnimation(
      to: layer,
      minOpacity: max(0.26, opacity * 0.48),
      maxOpacity: min(1.0, opacity),
      duration: max(0.2, cycleSeconds / 2.0),
      repeatCount: max(1, repeatCount) * 2
    )

    return layer
  }

  private func buildPulseLayer(
    geometry: EdgeGeometry,
    color: NSColor,
    opacity: CGFloat,
    cycleSeconds: CFTimeInterval,
    repeatCount: Int
  ) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.frame = geometry.frame
    layer.path = geometry.path
    layer.fillColor = NSColor.clear.cgColor
    layer.strokeColor = color.withAlphaComponent(opacity).cgColor
    layer.lineWidth = geometry.lineWidth
    layer.lineCap = .round
    layer.shadowColor = color.cgColor
    layer.shadowOffset = .zero
    layer.shadowRadius = max(7.0, geometry.lineWidth * 1.9)
    layer.shadowOpacity = Float(min(1.0, opacity + 0.18))
    layer.opacity = Float(opacity)
    layer.strokeStart = 0
    layer.strokeEnd = 1

    addOpacityPulseAnimation(
      to: layer,
      minOpacity: max(0.22, opacity * 0.28),
      maxOpacity: min(1.0, opacity),
      duration: max(0.2, cycleSeconds / 2.0),
      repeatCount: max(1, repeatCount) * 2
    )

    let widthPulse = CABasicAnimation(keyPath: "lineWidth")
    widthPulse.fromValue = max(1.0, geometry.lineWidth * 0.75)
    widthPulse.toValue = geometry.lineWidth * 1.2
    widthPulse.autoreverses = true
    widthPulse.duration = max(0.2, cycleSeconds / 2.0)
    widthPulse.repeatCount = Float(max(1, repeatCount) * 2)
    widthPulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    widthPulse.fillMode = .forwards
    widthPulse.isRemovedOnCompletion = false
    layer.add(widthPulse, forKey: "pulseLineWidth")

    return layer
  }

  private func buildDashLayer(
    geometry: EdgeGeometry,
    color: NSColor,
    opacity: CGFloat,
    cycleSeconds: CFTimeInterval,
    repeatCount: Int
  ) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.frame = geometry.frame
    layer.path = geometry.path
    layer.fillColor = NSColor.clear.cgColor
    layer.strokeColor = color.withAlphaComponent(opacity).cgColor
    layer.lineWidth = geometry.lineWidth
    layer.lineCap = .round
    layer.lineDashPattern = [
      NSNumber(value: max(4.0, Double(geometry.lineWidth * 1.2))),
      NSNumber(value: max(6.0, Double(geometry.lineWidth * 2.1))),
    ]
    layer.shadowColor = color.cgColor
    layer.shadowOffset = .zero
    layer.shadowRadius = max(6.0, geometry.lineWidth * 1.6)
    layer.shadowOpacity = Float(min(1.0, opacity + 0.1))
    layer.opacity = Float(opacity)
    layer.strokeStart = 0
    layer.strokeEnd = 1

    let dashCycle = max(50.0, Double(geometry.lineWidth * 14.0))
    let dashPhase = CABasicAnimation(keyPath: "lineDashPhase")
    dashPhase.fromValue = 0.0
    dashPhase.toValue = -dashCycle
    dashPhase.duration = cycleSeconds
    dashPhase.repeatCount = Float(max(1, repeatCount))
    dashPhase.timingFunction = CAMediaTimingFunction(name: .linear)
    dashPhase.fillMode = .forwards
    dashPhase.isRemovedOnCompletion = false
    layer.add(dashPhase, forKey: "dashFlow")

    addOpacityPulseAnimation(
      to: layer,
      minOpacity: max(0.25, opacity * 0.55),
      maxOpacity: min(1.0, opacity),
      duration: max(0.2, cycleSeconds / 2.0),
      repeatCount: max(1, repeatCount) * 2
    )

    return layer
  }

  private func buildCornerLayer(
    geometry: EdgeGeometry,
    color: NSColor,
    opacity: CGFloat,
    cycleSeconds: CFTimeInterval,
    repeatCount: Int
  ) -> CAShapeLayer {
    let segment = max(22.0, geometry.lineWidth * 3.2)
    let cornerPath = makeCornerPath(
      rect: geometry.roundedRect,
      cornerRadius: geometry.cornerRadius,
      segment: segment
    )

    let layer = CAShapeLayer()
    layer.frame = geometry.frame
    layer.path = cornerPath
    layer.fillColor = NSColor.clear.cgColor
    layer.strokeColor = color.withAlphaComponent(opacity).cgColor
    layer.lineWidth = max(1.0, geometry.lineWidth * 0.95)
    layer.lineCap = .round
    layer.shadowColor = color.cgColor
    layer.shadowOffset = .zero
    layer.shadowRadius = max(7.0, geometry.lineWidth * 2.0)
    layer.shadowOpacity = Float(min(1.0, opacity + 0.2))
    layer.opacity = Float(opacity)
    layer.strokeStart = 0
    layer.strokeEnd = 1

    let reveal = CABasicAnimation(keyPath: "strokeEnd")
    reveal.fromValue = 0.25
    reveal.toValue = 1.0
    reveal.autoreverses = true
    reveal.duration = max(0.2, cycleSeconds / 2.0)
    reveal.repeatCount = Float(max(1, repeatCount) * 2)
    reveal.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    reveal.fillMode = .forwards
    reveal.isRemovedOnCompletion = false
    layer.add(reveal, forKey: "cornerReveal")

    addOpacityPulseAnimation(
      to: layer,
      minOpacity: max(0.2, opacity * 0.45),
      maxOpacity: min(1.0, opacity),
      duration: max(0.2, cycleSeconds / 2.0),
      repeatCount: max(1, repeatCount) * 2
    )

    return layer
  }

  private func buildRainbowLayerGroup(
    geometry: EdgeGeometry,
    baseColor: NSColor,
    opacity: CGFloat,
    cycleSeconds: CFTimeInterval,
    repeatCount: Int
  ) -> CALayer {
    let container = CALayer()
    container.frame = geometry.frame

    let glowLayer = CAShapeLayer()
    glowLayer.frame = geometry.frame
    glowLayer.path = geometry.path
    glowLayer.fillColor = NSColor.clear.cgColor
    glowLayer.strokeColor = baseColor.withAlphaComponent(max(0.18, opacity * 0.26)).cgColor
    glowLayer.lineWidth = geometry.lineWidth * 1.35
    glowLayer.lineCap = .round
    glowLayer.shadowColor = baseColor.cgColor
    glowLayer.shadowOffset = .zero
    glowLayer.shadowRadius = max(9.0, geometry.lineWidth * 2.2)
    glowLayer.shadowOpacity = Float(min(1.0, opacity + 0.22))
    glowLayer.opacity = Float(max(0.2, opacity * 0.58))
    container.addSublayer(glowLayer)

    let gradient = CAGradientLayer()
    gradient.frame = geometry.frame
    gradient.colors = [
      NSColor.systemRed.withAlphaComponent(opacity).cgColor,
      NSColor.systemOrange.withAlphaComponent(opacity).cgColor,
      NSColor.systemYellow.withAlphaComponent(opacity).cgColor,
      NSColor.systemGreen.withAlphaComponent(opacity).cgColor,
      NSColor.cyan.withAlphaComponent(opacity).cgColor,
      NSColor.systemBlue.withAlphaComponent(opacity).cgColor,
      NSColor.systemPurple.withAlphaComponent(opacity).cgColor,
      NSColor.systemPink.withAlphaComponent(opacity).cgColor,
      NSColor.systemRed.withAlphaComponent(opacity).cgColor,
    ]
    gradient.locations = [
      NSNumber(value: 0.0),
      NSNumber(value: 0.14),
      NSNumber(value: 0.28),
      NSNumber(value: 0.42),
      NSNumber(value: 0.56),
      NSNumber(value: 0.7),
      NSNumber(value: 0.84),
      NSNumber(value: 0.92),
      NSNumber(value: 1.0),
    ]
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint = CGPoint(x: 1.0, y: 1.0)

    let maskLayer = CAShapeLayer()
    maskLayer.frame = geometry.frame
    maskLayer.path = geometry.path
    maskLayer.fillColor = NSColor.clear.cgColor
    maskLayer.strokeColor = NSColor.white.cgColor
    maskLayer.lineWidth = geometry.lineWidth
    maskLayer.lineCap = .round
    maskLayer.strokeStart = 0
    maskLayer.strokeEnd = 1
    gradient.mask = maskLayer
    container.addSublayer(gradient)

    let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
    rotate.fromValue = 0.0
    rotate.toValue = Double.pi * 2.0
    rotate.duration = cycleSeconds
    rotate.repeatCount = Float(max(1, repeatCount))
    rotate.timingFunction = CAMediaTimingFunction(name: .linear)
    rotate.fillMode = .forwards
    rotate.isRemovedOnCompletion = false
    gradient.add(rotate, forKey: "rainbowRotate")

    let shift = CABasicAnimation(keyPath: "locations")
    shift.fromValue = [
      NSNumber(value: 0.0), NSNumber(value: 0.14), NSNumber(value: 0.28),
      NSNumber(value: 0.42), NSNumber(value: 0.56), NSNumber(value: 0.7),
      NSNumber(value: 0.84), NSNumber(value: 0.92), NSNumber(value: 1.0),
    ]
    shift.toValue = [
      NSNumber(value: 1.0), NSNumber(value: 1.14), NSNumber(value: 1.28),
      NSNumber(value: 1.42), NSNumber(value: 1.56), NSNumber(value: 1.7),
      NSNumber(value: 1.84), NSNumber(value: 1.92), NSNumber(value: 2.0),
    ]
    shift.duration = cycleSeconds
    shift.repeatCount = Float(max(1, repeatCount))
    shift.timingFunction = CAMediaTimingFunction(name: .linear)
    shift.fillMode = .forwards
    shift.isRemovedOnCompletion = false
    gradient.add(shift, forKey: "rainbowShift")

    addOpacityPulseAnimation(
      to: container,
      minOpacity: max(0.4, opacity * 0.64),
      maxOpacity: 1.0,
      duration: max(0.25, cycleSeconds / 2.0),
      repeatCount: max(1, repeatCount) * 2
    )

    return container
  }

  private func addOpacityPulseAnimation(
    to layer: CALayer,
    minOpacity: CGFloat,
    maxOpacity: CGFloat,
    duration: CFTimeInterval,
    repeatCount: Int
  ) {
    let pulse = CABasicAnimation(keyPath: "opacity")
    pulse.fromValue = minOpacity
    pulse.toValue = maxOpacity
    pulse.autoreverses = true
    pulse.duration = duration
    pulse.repeatCount = Float(max(1, repeatCount))
    pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    pulse.fillMode = .forwards
    pulse.isRemovedOnCompletion = false
    layer.add(pulse, forKey: "opacityPulse")
  }

  private func makeCornerPath(
    rect: CGRect,
    cornerRadius: CGFloat,
    segment: CGFloat
  ) -> CGPath {
    let path = CGMutablePath()
    let seg = min(segment, min(rect.width, rect.height) * 0.28)
    let radius = max(8.0, min(cornerRadius, seg))

    path.move(to: CGPoint(x: rect.minX, y: rect.minY + seg))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
    path.addQuadCurve(
      to: CGPoint(x: rect.minX + radius, y: rect.minY),
      control: CGPoint(x: rect.minX, y: rect.minY)
    )
    path.addLine(to: CGPoint(x: rect.minX + seg, y: rect.minY))

    path.move(to: CGPoint(x: rect.maxX - seg, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
    path.addQuadCurve(
      to: CGPoint(x: rect.maxX, y: rect.minY + radius),
      control: CGPoint(x: rect.maxX, y: rect.minY)
    )
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + seg))

    path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - seg))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
    path.addQuadCurve(
      to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
      control: CGPoint(x: rect.maxX, y: rect.maxY)
    )
    path.addLine(to: CGPoint(x: rect.maxX - seg, y: rect.maxY))

    path.move(to: CGPoint(x: rect.minX + seg, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
    path.addQuadCurve(
      to: CGPoint(x: rect.minX, y: rect.maxY - radius),
      control: CGPoint(x: rect.minX, y: rect.maxY)
    )
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - seg))

    return path
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
