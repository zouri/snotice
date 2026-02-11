# SNotice Project Plan

## Project Overview

SNotice is a cross-platform desktop notification webhook application built with Flutter. It runs an HTTP server (default port 8642) that accepts REST API requests to trigger system notifications on macOS, Linux, and Windows. The app features a settings UI, request logging, system tray integration, and flash screen overlay notifications.

## Technology Stack

- **Framework**: Flutter 3.10.7+
- **HTTP Server**: shelf
- **Local Notifications**: flutter_local_notifications
- **System Tray**: system_tray
- **State Management**: provider
- **Configuration Persistence**: shared_preferences
- **Logging**: logger
- **Multi-window**: desktop_multi_window (for flash screen feature)
- **Window Management**: window_manager

## Project Structure

```
lib/
├── main.dart                          # Application entry point
├── config/
│   └── constants.dart                  # Application constants
├── models/
│   ├── notification_request.dart         # Notification request model
│   ├── app_config.dart                 # Application configuration model
│   └── log_entry.dart                 # Log entry model
├── services/
│   ├── http_server_service.dart         # HTTP server service
│   ├── notification_service.dart        # Notification service
│   ├── tray_service.dart               # System tray service
│   ├── config_service.dart             # Configuration service
│   ├── logger_service.dart             # Logging service
│   └── flash_overlay_service.dart      # Flash screen overlay service
├── providers/
│   ├── config_provider.dart            # Configuration state management
│   ├── log_provider.dart               # Log state management
│   └── server_provider.dart           # Server state management
├── ui/
│   ├── main_screen.dart               # Main interface
│   ├── settings_screen.dart           # Settings interface
│   ├── log_screen.dart                # Log interface
│   └── test_screen.dart              # Test interface
└── utils/
    ├── response_util.dart             # HTTP response utilities
    └── ip_utils.dart                # IP address utilities
```

## API Endpoints

### POST /api/notify

Send a notification to the system.

**Request Body:**
```json
{
  "title": "string (required)",
  "body": "string (required)",
  "icon": "string (optional)",
  "priority": "low|normal|high (optional, default: normal)",
  "category": "string (optional)",
  "flashColor": "string (optional, for flash category)",
  "flashDuration": "int (optional, default: 500, for flash category)",
  "payload": "object (optional)"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Notification sent",
  "timestamp": "2026-01-13T10:30:00.000Z"
}
```

### GET /api/status

Get the current server status.

**Response:**
```json
{
  "running": true,
  "port": 8642,
  "uptime": 3600
}
```

### GET /api/config

Get the current configuration.

**Response:**
```json
{
  "port": 8642,
  "allowedIPs": ["127.0.0.1", "::1"],
  "autoStart": true,
  "showNotifications": true
}
```

### POST /api/config

Update the configuration.

**Request Body:**
```json
{
  "port": 8642,
  "allowedIPs": ["127.0.0.1"],
  "autoStart": false
}
```

## Data Models

### NotificationRequest

```dart
class NotificationRequest {
  String title;
  String body;
  String? icon;
  String? priority; // low, normal, high
  String? category; // "flash" for screen flash
  String? flashColor;
  int? flashDuration;
  Map<String, dynamic>? payload;
}
```

### AppConfig

```dart
class AppConfig {
  int port;
  List<String> allowedIPs;
  bool autoStart;
  bool showNotifications;
}
```

### LogEntry

```dart
class LogEntry {
  DateTime timestamp;
  String type; // request, notification, error
  String message;
  Map<String, dynamic>? data;
}
```

## Usage Examples

### cURL Example

```bash
curl -X POST http://localhost:8642/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "body": "This is a notification from SNotice",
    "priority": "high"
  }'
```

### Flash Screen Example

```bash
curl -X POST http://localhost:8642/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Alert",
    "body": "Screen flash",
    "category": "flash",
    "flashColor": "gray",
    "flashDuration": 800
  }'
```

## Security Considerations

- **IP Whitelist**: Default allows only localhost access
- **Configurable Port**: Avoid port conflicts
- **Input Validation**: Validate all input parameters
- **HTTPS Support**: Consider using HTTPS in production environments

## Performance Considerations

- Async notification sending
- Log rotation to prevent memory overflow
- HTTP connection pooling
- In-memory log storage with auto-rotation (max 1000 entries)

## Platform-Specific Notes

- **macOS**: Native notifications and system tray
- **Linux**: GTK-based notifications and tray
- **Windows**: Windows notifications and system tray

Each platform requires building the respective target before running in release mode.

## License

MIT
