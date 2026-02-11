# PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-11
**Project:** SNotice - Cross-platform desktop notification webhook
**Commit:** Working tree
**Branch:** Current

## LAYER-SPECIFIC KNOWLEDGE

This file contains both high-level project knowledge and layer-specific documentation. See sections below for detailed layer information.

## OVERVIEW

Cross-platform desktop notification webhook (Flutter) with HTTP server, system tray integration, and flash screen overlays. REST API on port 8642 sends system notifications on macOS/Linux/Windows.

## STRUCTURE

```
./
├── lib/
│   ├── main.dart           # Primary entry point with app initialization
│   ├── overlay_main.dart   # Overlay app entry (flash screen, invoked conditionally)
│   ├── config/             # Constants
│   ├── models/             # Data models (AppConfig, LogEntry, NotificationRequest)
│   ├── providers/          # State management (ConfigProvider, ServerProvider, LogProvider)
│   ├── services/           # Business logic (HTTP server, notifications, config, logging, tray)
│   ├── ui/                 # UI screens (MainScreen, SettingsScreen, LogScreen, TestScreen)
│   └── utils/              # Utilities (ResponseUtil, IPUtils)
├── test/                   # Unit tests (ip_utils_test.dart)
└── docs/                   # Project documentation (see README.md)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| App initialization | lib/main.dart | Services, providers, HTTP server, tray setup |
| HTTP server endpoints | lib/services/http_server_service.dart | POST /api/notify, GET /api/status, /api/config |
| State providers | lib/providers/ | Config, Server, Log providers using ChangeNotifier |
| UI screens | lib/ui/ | Main (dashboard), Settings, Log viewer, Test screen |
| Notification handling | lib/services/notification_service.dart | flutter_local_notifications, platform-specific |
| Flash screen overlay | lib/overlay_main.dart, lib/services/flash_overlay_service.dart | Separate Flutter app for overlay effect |

---

## LAYER-SPECIFIC KNOWLEDGE

### Service Layer

**Purpose:** Business logic, external integrations, and platform-specific features

**Service Overview:**
- HTTP API - lib/services/http_server_service.dart - REST endpoints (POST /api/notify, GET /api/status, GET/POST /api/config)
- Notifications - lib/services/notification_service.dart - flutter_local_notifications wrapper
- Configuration - lib/services/config_service.dart - SharedPreferences persistence
- Logging - lib/services/logger_service.dart - In-memory log storage (max 1000 entries)
- System tray - lib/services/tray_service.dart - Desktop tray integration
- Flash overlay - lib/services/flash_overlay_service.dart - Full-screen overlay notifications

**Service Layer Conventions:**
- All services use constructor DI: dependencies as `private final` fields
- Public APIs expose only necessary operations
- Async operations initialized in `main()` before `runApp()`
- Use `LoggerService` via dependency injection (never import logger directly)
- Return Future for async operations, mark with `Future<T>` type
- Validate inputs before processing (especially in HTTP handler)
- Use `ResponseUtil` for consistent HTTP error responses
- Platform-specific code (tray, notifications) conditionally compiled

**Anti-Patterns (Service Layer):**
- Direct logger imports: Services should receive LoggerService via DI, not import global logger
- Inline validation: Complex validation logic should be extracted to model validators
- Mixed concerns: HTTP handlers should delegate to services, not contain business logic directly

### UI Layer

**Purpose:** UI screens and widget patterns for SNotice desktop app

**UI Overview:**
- Main dashboard - lib/ui/main_screen.dart - Server status, quick actions, navigation
- Settings interface - lib/ui/settings_screen.dart - Port, IP whitelist, auto-start configuration
- Log viewer - lib/ui/log_screen.dart - Request history, filtering, search
- Testing interface - lib/ui/test_screen.dart - Manual notification testing, API endpoint display

**UI Layer Conventions:**
- Screen widgets extend `StatefulWidget` when state-dependent, `StatelessWidget` for static layouts
- All screens consume providers via `Consumer<ProviderType>` for reactive updates
- Use `Scaffold` as root widget with `appBar` and `body`
- Use `Card` + `ListTile` for list-based data display
- Use `ElevatedButton` for primary actions, `TextButton` for secondary
- Navigation uses `Navigator.push()` with `MaterialPageRoute`
- Use `ScaffoldMessenger` for snackbars/alerts, check `context.mounted` after async ops
- Spacing via `SizedBox(height/width: X)` consistently
- Color scheme follows Material Theme defaults

**Anti-Patterns (UI Layer):**
- Large screen files: test_screen.dart (335 lines), settings_screen.dart (267 lines) - consider widget extraction for reuse
- Hardcoded strings: UI text should reference constants or localization keys (not yet implemented)

---

## ANTI-PATTERNS (THIS PROJECT)

- **Relative imports in tests**: test/ip_utils_test.dart uses `../lib/utils/ip_utils.dart` instead of `package:snotice_new/utils/ip_utils.dart`
- **Multiple entry points**: overlay_main.dart is a separate entry point invoked from main.dart under specific conditions (non-MacOS + window args)
- **No CI automation**: Build/test steps are documented in docs/ but no .github/workflows or Makefile exists
- **TODO in CMakeLists**: windows/flutter/CMakeLists.txt and linux/flutter/CMakeLists.txt have TODO comments about refactoring

## UNIQUE STYLES

- **Dual entry point flow**: main.dart routes to overlay_main.dart for flash screen notifications on non-macOS platforms
- **Provider pattern for state**: All state uses Provider (ConfigProvider, ServerProvider, LogProvider) with ChangeNotifier
- **Shelf-based HTTP server**: Custom shelf implementation with middleware for CORS and IP whitelist
- **In-memory logging**: LoggerService with auto-rotation (max 1000 entries), no persistent log storage
- **Desktop-first**: Platform-specific features (tray, flash overlay) for macOS/Linux/Windows

## NOTES

- **Chinese pub mirror**: docs use PUB_HOSTED_URL=https://pub.flutter-io.cn for faster downloads
- **Overlay entry**: When window controller arguments contain color data on non-macOS, overlayMain() is invoked instead of main app
- **Test coverage**: Minimal - only ip_utils_test.dart exists
- **Platform builds**: Must build for specific platform (macos/linux/windows) before running in release mode

---

## Build, Lint, and Test Commands

```bash
# Install dependencies
flutter pub get

# Code analysis (lint)
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

## Code Style Guidelines

### Imports
- Organize imports: package imports first, then relative imports using `../` prefix
- Separate groups with blank lines: Flutter/external packages, then internal imports
- Example:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../models/app_config.dart';
  import '../services/logger_service.dart';
  ```

### Naming Conventions
- **Classes**: PascalCase (e.g., `NotificationService`, `AppConfig`)
- **Variables/Methods**: camelCase (e.g., `port`, `allowedIPs`, `startServer()`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `defaultPort`, `appName`)
- **Private members**: Prefix with underscore `_` (e.g., `_logger`, `_config`)

### Formatting
- Use 2-space indentation
- Trailing commas in multi-line lists/function arguments
- Wrap long lines at 80 characters
- Use const constructors where possible

### Type Annotations
- Always annotate class fields with explicit types
- Annotate method parameters and return types (except simple cases)
- Use nullable types (`Type?`) appropriately
- Use `as Type?` for safe casting with null fallbacks

### Error Handling
- Wrap I/O operations in try-catch blocks
- Log errors using `logger.error()` method
- Rethrow exceptions when appropriate using `rethrow`
- Return early for error conditions in handlers
- Use `ResponseUtil` for HTTP error responses (see `lib/utils/response_util.dart`)

### Models and Serialization
- Implement `fromJson()` factory constructor for deserialization
- Implement `toJson()` method for serialization
- Implement `copyWith()` method for immutable updates
- Use nullable types with `??` operator for default values
- Example:
  ```dart
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      port: json['port'] as int? ?? 8642,
      allowedIPs: (json['allowedIPs'] as List<dynamic>?)
          ?.map((e) => e as String).toList() ?? [],
    );
  }
  ```

### Services
- Use dependency injection via constructor parameters
- Store dependencies as private final fields
- Use getter methods for computed properties
- Provide public APIs only for necessary operations
- Initialize async operations in `main()` before `runApp()`

### State Management (Provider)
- Extend `ChangeNotifier` for state providers
- Call `notifyListeners()` after state changes
- Use `Consumer<N>` widgets in UI for rebuilding
- Use `Provider.of<ProviderType>(context, listen: false)` for read-only access
- Use `context.mounted` check before showing dialogs/snackbars after async ops

### UI Components
- Extend `StatelessWidget` for static widgets, `StatefulWidget` for dynamic
- Use `const` constructors where possible
- Use `ScaffoldMessenger` for showing snacks and alerts
- Use `Navigator` for page transitions with `MaterialPageRoute`
- Use `Card`, `ListTile`, `ElevatedButton` from Material Design
- Use `SizedBox` for spacing

### Async/Await
- Mark async methods with `Future<T>` return type
- Use `await` for all async operations
- Initialize async resources in `main()` before UI starts
- Use `WidgetsFlutterBinding.ensureInitialized()` for plugin init

### HTTP API
- Use `shelf` and `shelf_router` for server implementation
- Use middleware for cross-cutting concerns (CORS, auth)
- Return consistent JSON responses using `ResponseUtil`
- Log all requests using `logger.request()` method
- Validate input using model validation methods

### Project Structure
- `lib/config/` - Configuration constants
- `lib/models/` - Data models with serialization
- `lib/services/` - Business logic and external integrations
- `lib/providers/` - State management (Provider pattern)
- `lib/ui/` - UI screens and widgets
- `lib/utils/` - Utility functions and helpers

### Testing
- Write unit tests in `test/` directory (not yet created)
- Use `flutter_test` framework
- Mock dependencies using `mockito`
- Test file naming: `filename_test.dart`

### Linting
- Follow `flutter_lints` rules (see `analysis_options.yaml`)
- Run `flutter analyze` before committing
- Fix all analyzer warnings and errors
