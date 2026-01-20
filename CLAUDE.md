# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SNotice is a cross-platform desktop notification webhook application built with Flutter. It runs an HTTP server (default port 8080) that accepts REST API requests to trigger system notifications on macOS, Linux, and Windows. The app features a settings UI, request logging, and system tray integration.

## Development Commands

### Dependency Installation
```bash
# Use Chinese mirror for faster downloads
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
flutter pub get
```

### Running the App
```bash
# Debug mode (platform-specific)
flutter run -d macos
flutter run -d linux
flutter run -d windows

# Release mode (requires build first)
flutter build macos --release
flutter run --release -d macos
```

### Testing & Analysis
```bash
# Static analysis
flutter analyze

# Run tests (no unit tests currently implemented)
flutter test
```

### Building for Release
```bash
flutter build macos --release
flutter build linux --release
flutter build windows --release
```

## Architecture

### State Management: Provider Pattern
The app uses the Provider package for reactive state management with three main providers:
- **ConfigProvider** ([lib/providers/config_provider.dart](lib/providers/config_provider.dart)) - Manages application configuration (port, allowed IPs, auto-start settings)
- **ServerProvider** ([lib/providers/server_provider.dart](lib/providers/server_provider.dart)) - Controls HTTP server lifecycle (start/stop, status tracking)
- **LogProvider** ([lib/providers/log_provider.dart](lib/providers/log_provider.dart)) - Maintains log entries with filtering capabilities

### Service Layer
Business logic is separated into dedicated services in [lib/services/](lib/services/):
- **HttpServerService** - Shelf-based HTTP server with middleware (CORS, IP whitelist)
- **NotificationService** - Cross-platform notification handling via flutter_local_notifications
- **ConfigService** - Configuration persistence using SharedPreferences
- **LoggerService** - In-memory logging with automatic rotation (max 1000 entries)
- **TrayService** - System tray functionality

### API Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/notify` | Send system notification |
| GET | `/api/status` | Server status and uptime |
| GET | `/api/config` | Current configuration |
| POST | `/api/config` | Update configuration |

### Configuration Constants
Default values are defined in [lib/config/constants.dart](lib/config/constants.dart):
- Port: `8080`
- Allowed IPs: `['127.0.0.1', '::1']` (localhost only)
- Max log entries: `1000`
- Notification channel ID: `snotice_channel`

## Key Implementation Details

### HTTP Server Middleware Pipeline
The server uses Shelf middleware for CORS support and IP whitelist validation. All requests are logged automatically.

### Notification System
Uses `flutter_local_notifications` package with platform-specific initialization. Supports priority levels (low, normal, high) and custom categories.

### Log Management
Logs are stored in-memory with automatic rotation when exceeding 1000 entries. Supports filtering by type (INFO, ERROR, WARNING, REQUEST, NOTIFICATION) and date range.

### System Tray
Platform-specific tray implementation with start/stop server controls. The app can minimize to tray instead of closing.

## File Structure

```
lib/
├── main.dart                 # App entry point
├── config/constants.dart     # App constants
├── models/                   # Data models (AppConfig, LogEntry, NotificationRequest)
├── providers/                # State management (ConfigProvider, ServerProvider, LogProvider)
├── services/                 # Business logic (HTTP server, notifications, config, logging, tray)
├── ui/                       # UI screens (MainScreen, SettingsScreen, LogScreen, TestScreen)
└── utils/response_util.dart  # HTTP response utilities
```

## Platform-Specific Notes

- **macOS**: Native notifications and system tray
- **Linux**: GTK-based notifications and tray
- **Windows**: Windows notifications and system tray

Each platform requires building the respective target before running in release mode.
