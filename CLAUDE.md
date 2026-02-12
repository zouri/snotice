# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build, Test, and Development Commands

```bash
# Install dependencies
flutter pub get

# Run code analysis/linting
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/file_name_test.dart

# Run on specific platform
flutter run -d macos
flutter run -d linux
flutter run -d windows

# Build for release
flutter build macos --release
flutter build linux --release
flutter build windows --release
```

## High-Level Architecture

SNotice is a cross-platform desktop notification webhook application built with Flutter. The app runs an HTTP server (default port 8642) that accepts POST requests to trigger system notifications and flash screen overlays.

### Dual Entry Point Pattern

The application uses a dual entry point flow:

- **`lib/main.dart`**: Primary entry point for the main application. Initializes services, providers, HTTP server, and system tray.
- **`lib/overlay_main.dart`**: Separate entry point for flash overlay notifications. Invoked conditionally on non-macOS platforms when window arguments contain flash parameters.

On macOS, flash overlays are implemented natively in Swift (`macos/Runner/MainFlutterWindow.swift`) using NSPanel, avoiding the need for a separate Flutter window.

### Application Initialization Flow

1. `main()` checks platform and window arguments
2. If non-macOS with flash arguments → delegates to `overlay_main.dart`
3. Otherwise → initializes main app via `_startMainApp()`
4. Services are created with dependency injection
5. Providers registered with `MultiProvider`
6. System tray initialized
7. HTTP server auto-starts if `config.autoStart == true`

### Service Layer Architecture

All services use constructor dependency injection with `private final` fields. Services should never import `LoggerService` directly - always receive it via constructor injection.

**Key services:**
- `HttpServerService` - REST API with shelf framework
- `NotificationService` - System notifications via flutter_local_notifications
- `FlashOverlayService` - Platform-specific flash screen (native on macOS, desktop_multi_window on others)
- `ConfigService` - Configuration persistence with SharedPreferences
- `LoggerService` - In-memory log storage (max 1000 entries)
- `TrayService` - System tray integration

### State Management

Uses Provider pattern with ChangeNotifier:
- `ConfigProvider` - Application configuration
- `ServerProvider` - HTTP server state (isRunning, start/stop)
- `LogProvider` - Log history display

All providers are initialized in `main()` before `runApp()` and consumed in UI using `Consumer<T>` widgets.

### HTTP API

Implemented with `shelf` and `shelf_router`:

- `POST /api/notify` - Send notification or trigger flash
- `GET /api/status` - Server status and uptime
- `GET /api/config` - Get current configuration
- `POST /api/config` - Update configuration

Middleware chain:
1. CORS headers (all origins)
2. IP whitelist enforcement
3. Route handler

Use `ResponseUtil` (lib/utils/response_util.dart) for consistent JSON responses.

### Platform-Specific Flash Overlay

**macOS** (`macos/Runner/MainFlutterWindow.swift`):
- Uses native NSPanel with `NSWindow.Level.screenSaver`
- Multi-monitor support via `NSScreen.screens`
- MethodChannel `snotice/flash` for Flutter communication
- Covers menu bar and all Spaces using `canJoinAllSpaces`

**Other platforms** (`lib/overlay_main.dart`):
- Uses `desktop_multi_window` package
- Creates separate hidden Flutter window with arguments
- `windowManager` for full-screen transparent overlay

Detection happens in `main()` - macOS never routes to overlay_main.dart.

## Code Structure

```
lib/
├── main.dart              # Primary entry point, app initialization
├── overlay_main.dart      # Overlay app entry (non-macOS flash screens)
├── config/
│   └── constants.dart     # AppConstants (port, channel IDs, defaults)
├── models/
│   ├── app_config.dart    # AppConfig with JSON serialization
│   ├── notification_request.dart  # Notification request model
│   └── log_entry.dart     # Log entry model
├── providers/
│   ├── config_provider.dart
│   ├── server_provider.dart
│   └── log_provider.dart
├── services/
│   ├── http_server_service.dart
│   ├── notification_service.dart
│   ├── flash_overlay_service.dart
│   ├── config_service.dart
│   ├── logger_service.dart
│   └── tray_service.dart
├── ui/
│   ├── main_screen.dart
│   ├── settings_screen.dart
│   ├── log_screen.dart
│   └── test_screen.dart
└── utils/
    ├── response_util.dart
    └── ip_utils.dart
```

## Key Conventions

### Service Dependencies
Services receive `LoggerService` via constructor injection:
```dart
class HttpServerService {
  final NotificationService _notificationService;
  final LoggerService _logger;

  HttpServerService({
    required NotificationService notificationService,
    required LoggerService logger,
  }) : _notificationService = notificationService,
       _logger = logger;
}
```

### Model Serialization
All models implement `fromJson()` factory and `toJson()` method with nullable-safe casting:
```dart
factory AppConfig.fromJson(Map<String, dynamic> json) {
  return AppConfig(
    port: json['port'] as int? ?? 8642,
    allowedIPs: (json['allowedIPs'] as List<dynamic>?)
        ?.map((e) => e as String).toList() ?? defaultAllowedIPs,
  );
}
```

### HTTP Response Pattern
Use `ResponseUtil` for consistent responses:
```dart
return ResponseUtil.success({'key': 'value'});
return ResponseUtil.badRequest('Invalid input');
return ResponseUtil.unauthorized('IP not allowed');
return ResponseUtil.serverError('Internal error');
```

### Provider Consumption
Use `Consumer<T>` for reactive updates in UI:
```dart
Consumer<ServerProvider>(
  builder: (context, serverProvider, child) {
    return Text(serverProvider.isRunning ? 'Running' : 'Stopped');
  },
)
```

## Platform Detection

Use `Platform` from `dart:io` for conditional behavior:
```dart
import 'dart:io';

if (Platform.isMacOS) {
  // Native implementation
} else {
  // desktop_multi_window implementation
}
```

## IP Whitelist Format

IP whitelist supports both individual IPs and CIDR notation:
- Individual: `127.0.0.1`, `::1`
- CIDR: `192.168.1.0/24`, `fe80::/10`

Validation logic in `AppConfig.isIP()` and `IPUtils` utilities.
