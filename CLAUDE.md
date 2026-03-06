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

# Test HTTP API with Python script
python3 scripts/test_http_api.py status              # Check server status
python3 scripts/test_http_api.py notify --mode flash # Send flash notification
python3 scripts/test_http_api.py smoke               # Run smoke test
python3 scripts/test_http_api.py --help              # Show all options
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
- `ThemeProvider` - Theme mode (system/light/dark) with persistence
- `LocaleProvider` - Language preference (system/English/Chinese) with persistence

All providers are initialized in `main()` before `runApp()` and consumed in UI using `Consumer<T>` widgets.

**Provider-Service Integration:**
- `LocaleProvider` is connected to `TrayService` via `setLocaleProvider()` to enable localized system tray menus
- When locale changes, tray menu automatically rebuilds with new language strings
- `ThemeProvider` persists user preference across app restarts using SharedPreferences

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
│   ├── theme_provider.dart
│   └── locale_provider.dart
├── services/
│   ├── http_server_service.dart
│   ├── notification_service.dart
│   ├── flash_overlay_service.dart
│   ├── config_service.dart
│   ├── logger_service.dart
│   └── tray_service.dart
├── ui/
│   ├── screens/
│   │   ├── app_shell.dart       # Main navigation shell with sidebar
│   │   ├── home_screen.dart     # Settings screen
│   │   ├── call_log_page.dart   # Call log display
│   │   └── http_api_page.dart   # API documentation page
│   └── widgets/
│       ├── main/                # Shared UI components
│       └── settings/            # Settings-specific widgets
├── l10n/
│   ├── app_localizations.dart       # Generated localizations base
│   ├── app_localizations_en.dart    # English translations
│   └── app_localizations_zh.dart    # Chinese translations
├── theme/
│   ├── theme.dart              # Theme exports
│   ├── app_theme.dart          # Light/dark theme definitions
│   ├── app_colors.dart         # Color palette
│   ├── app_text_styles.dart    # Typography
│   ├── app_spacing.dart        # Spacing constants
│   ├── app_animation.dart      # Animation constants
│   └── app_breakpoints.dart    # Responsive breakpoints
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

// Multiple providers
Consumer2<ThemeProvider, LocaleProvider>(
  builder: (context, themeProvider, localeProvider, child) {
    return MaterialApp(
      themeMode: themeProvider.mode,
      locale: localeProvider.locale,
    );
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

## Internationalization (i18n)

The application supports multiple languages using Flutter's built-in localization system.

**Supported Languages:**
- English (en_US)
- Chinese Simplified (zh_CN)

**Architecture:**
- Translations defined in `lib/l10n/` (generated from ARB files)
- `LocaleProvider` manages language preference with persistence
- Users can choose: System default, English, or Chinese
- System tray menu automatically updates when language changes

**Usage in Code:**
```dart
// Access localized strings
final l10n = AppLocalizations.of(context)!;
Text(l10n.navSettings)

// Change language
localeProvider.setLocale(Locale('zh', 'CN'));  // Chinese
localeProvider.setLocale(null);  // System default
```

**Adding New Strings:**
1. Add key to `lib/l10n/app_en.arb` and `app_zh.arb`
2. Run `flutter gen-l10n` to generate Dart code
3. Access via `AppLocalizations.of(context)!.keyName`

## UI Navigation Pattern

The app uses a sidebar navigation pattern with `AppShell` as the root widget:

**Navigation Structure:**
- `AppShell` - Root container with sidebar and content area
- Three main tabs: Call Logs, HTTP API, Settings
- `IndexedStack` preserves tab state when switching
- Sidebar shows server status at bottom

**Sidebar Implementation:**
- Defined in `ui/screens/app_shell.dart`
- Uses `_ShellTab` enum for navigation state
- Integrates with `ServerProvider` for status indicator
- Responsive dimensions defined in `ShellDimensions`

**Consumer Pattern:**
```dart
// Sidebar shows real-time server status
Consumer<ServerProvider>(
  builder: (context, serverProvider, _) {
    final isRunning = serverProvider.isRunning;
    return Text(isRunning ? 'Running' : 'Stopped');
  },
)
```

## Theme System

The application uses a comprehensive theme system with light/dark mode support.

**Theme Architecture:**
- `ThemeProvider` manages theme mode (system/light/dark)
- `AppTheme` defines Material 3 color schemes and component themes
- Theme automatically persists across app restarts
- System theme follows OS dark mode setting

**Theme Components:**
- `app_colors.dart` - Brand and semantic color definitions
- `app_text_styles.dart` - Typography scale
- `app_spacing.dart` - Spacing and padding constants
- `app_animation.dart` - Animation durations and curves

**Usage:**
```dart
// Toggle theme
themeProvider.toggle();  // Light ↔ Dark

// Set specific mode
themeProvider.setDark();
themeProvider.setLight();
themeProvider.setSystem();  // Follow OS

// Check current mode
if (themeProvider.isDarkMode) { ... }
```
