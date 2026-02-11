# Flash Screen Notifications

## Overview

SNotice supports full-screen flash overlay notifications that display a transparent overlay across the entire screen, even over full-screen applications. This feature is useful for emergency alerts and important notifications.

## Quick Start

### Test via UI
1. Start the app: `flutter run -d macos`
2. Click the "Test" button in the top-right corner
3. Select Category: **Flash (Screen)**
4. Choose a color by clicking the color button
5. Set duration (default: 500ms)
6. Click "Send Notification"
7. Observe the full-screen flash effect

### Test via HTTP API

```bash
# Red emergency flash
curl -X POST http://localhost:8642/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Alert",
    "body": "Check screen",
    "category": "flash",
    "flashColor": "#FF0000"
  }'

# Gray overlay (recommended for notifications)
curl -X POST http://localhost:8642/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Notification",
    "body": "Screen flash",
    "category": "flash",
    "flashColor": "gray",
    "flashDuration": 800
  }'

# Yellow warning flash, 1 second
curl -X POST http://localhost:8642/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Warning",
    "body": "Attention",
    "category": "flash",
    "flashColor": "yellow",
    "flashDuration": 1000
  }'
```

## API Parameters

```json
{
  "title": "string (required)",
  "body": "string (required)",
  "category": "flash",
  "flashColor": "string (optional, default: #FF0000)",
  "flashDuration": "int (optional, default: 500)"
}
```

### Parameter Details
- `category`: Must be set to `"flash"` to trigger screen flash
- `flashColor`: Flash overlay color
  - Hex format: `"#FF0000"`, `"0xFFFF0000"`
  - Color names: `"red"`, `"blue"`, `"green"`, `"yellow"`, `"white"`, `"gray"`, `"orange"`, `"purple"`, `"pink"`, `"cyan"`
- `flashDuration`: Flash duration in milliseconds, default: 500ms

## Supported Colors

### Hex Format
- `#FF0000` - Red
- `#00FF00` - Green
- `#0000FF` - Blue
- `#FFFFFF` - White
- `#864280` - Gray
- `#FFA500` - Orange

### Color Names
- `red`, `blue`, `green`, `yellow`
- `white`, `black`, `gray` (or `grey`)
- `orange`, `purple`, `pink`, `cyan`

## Recommended Configurations

### Emergency Alert
```json
{
  "flashColor": "#FF0000",
  "flashDuration": 500
}
```

### Gentle Reminder
```json
{
  "flashColor": "gray",
  "flashDuration": 800
}
```

### Warning
```json
{
  "flashColor": "yellow",
  "flashDuration": 1000
}
```

## Technical Implementation

### Architecture Flow
```
Main Application (SNotice)
    ↓ HTTP API Request
NotificationService
    ↓ Detects category == 'flash'
FlashOverlayService
    ↓ Creates overlay window
DesktopMultiWindow Plugin
    ↓ Creates independent window
overlay_main.dart (Overlay window entry)
    ↓ Displays flash animation
FlashOverlayScreen
```

### Technology Stack
- `desktop_multi_window` - Multi-window creation
- `window_manager` - Window management
- `provider` - State management

### Key Files
- `lib/overlay_main.dart` - Overlay window entry point
- `lib/services/flash_overlay_service.dart` - Flash overlay service
- `lib/services/notification_service.dart` - Notification service
- `lib/models/notification_request.dart` - Data model

## Window Configuration

### Current Implementation

**Window Configuration (overlay_main.dart)**
```dart
Future<void> _configureOverlayWindow() async {
  const windowOptions = WindowOptions(
    size: Size(1920, 1080),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();

    // Key settings
    await windowManager.setOpacity(0.5);        // 50% transparency
    await windowManager.setSkipTaskbar(true);   // Hide from taskbar
    await windowManager.setAlwaysOnTop(true);   // Always on top
    await windowManager.setFullScreen(true);    // Full screen mode
  });
}
```

**Flash Service Configuration (flash_overlay_service.dart)**
```dart
// Configure after window creation
await controller.invokeMethod('setOpacity', 0.5);        // 50% transparency
await controller.invokeMethod('setSkipTaskbar', true);   // Hide from taskbar
await controller.invokeMethod('setAlwaysOnTop', true);   // Always on top
await controller.invokeMethod('setFullScreen', true);    // Full screen mode
await controller.invokeMethod('setTransparent', true);   // Transparent background
```

### Key Properties

| Property | Value | Purpose |
|----------|-------|---------|
| Opacity | 0.5 (50%) | Semi-transparent overlay, allows viewing content below |
| Full Screen | true | Covers entire screen |
| Always On Top | true | Window remains above all other applications |
| Skip Taskbar | true | Hides from taskbar to prevent accidental clicks |
| Transparent | true | Window background transparent, only shows flash color |

### Window Layer Architecture
```
User Desktop
    ↓
Other Application Windows
    ↓
Overlay Window (Always on top, Full screen, 50% transparent)
    ↓
Flash Animation Layer (displays color based on opacity)
```

## Visual Effect

1. **Fade In**: Screen gradually displays transparent overlay (0% → 80% color opacity)
2. **Hold**: Overlay remains visible for specified duration
3. **Fade Out**: Overlay gradually fades away (80% → 0% color opacity)
4. **Close**: Overlay window automatically closes

### Coverage
- ✅ Full screen coverage
- ✅ Covers all applications (including full-screen apps)
- ✅ Always on top
- ✅ 50% transparency (adjustable)

## Transparency Details

```
Window Transparency: 50% (0.5)
    ↓
Color Opacity Animation: 0% → 80% → 0%
    ↓
Final Effect: 50% × Color Opacity
```

Examples:
- Red flash with 80% color opacity → Final display: 50% red
- Gray overlay with 80% color opacity → Final display: 50% gray

## Adjustable Parameters

### In overlay_main.dart
```dart
// Transparency (0.0 - 1.0)
await windowManager.setOpacity(0.5);  // 50%

// Full screen
await windowManager.setFullScreen(true);
```

### In FlashOverlayScreen
```dart
// Maximum color opacity
_opacityAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(...);
```

## Troubleshooting

### Issue 1: Window Not Displayed
**Cause**: Dependencies not installed or platform not configured
**Solution**:
```bash
flutter pub get
flutter clean && flutter run -d macos
```

### Issue 2: Window Not Full Screen
**Cause**: window_manager not properly initialized
**Solution**: Check `_configureOverlayWindow()` function in `overlay_main.dart`

### Issue 3: Window Not Transparent
**Cause**: Missing platform-specific configuration
**Solution**: Verify platform code for transparency support

### Issue 4: Window Not Always on Top
**Cause**: `setAlwaysOnTop` not taking effect
**Solution**: Ensure it's called after displaying the window, check platform permissions

### Issue 5: Flash Not Working
**Cause**: Category not set to "flash"
**Solution**: Ensure API request includes `"category": "flash"`

## Testing Checklist

- [ ] `flutter pub get`
- [ ] `flutter run -d macos`
- [ ] Start server
- [ ] Send test notification via UI
- [ ] Verify full-screen overlay appears
- [ ] Check overlay covers all applications
- [ ] Verify semi-transparent effect
- [ ] Confirm window closes automatically

## Status

✅ Implementation Complete
- Transparency: 50%
- Coverage: Full screen + Always on top
- Platform Support: macOS, Linux, Windows

## License

MIT
