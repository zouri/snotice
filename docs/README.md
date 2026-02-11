# SNotice

A cross-platform desktop notification webhook application for macOS, Linux, and Windows.

## Features

- 📢 **System Notifications**: Send notifications via HTTP API
- 🌐 **HTTP Webhook**: RESTful API endpoint for sending notifications
- ⚙️ **Configurable UI**: Full-featured settings interface
- 📝 **Logging**: Complete request and notification history
- 📋 **System Tray**: Minimizable to system tray
- 🔒 **IP Whitelist**: Simple IP-based access control
- 🎨 **Flash Screen**: Full-screen overlay notifications with custom colors

## Quick Start

### Install Dependencies

```bash
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
flutter pub get
```

### Run the Application

```bash
# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

## API Usage

### Send a Notification

```bash
curl -X POST http://localhost:8642/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Hello",
    "body": "This is a notification",
    "priority": "high"
  }'
```

### Flash Screen Notification

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

### Get Server Status

```bash
curl http://localhost:8642/api/status
```

### Get/Update Configuration

```bash
# Get config
curl http://localhost:8642/api/config

# Update config
curl -X POST http://localhost:8642/api/config \
  -H "Content-Type: application/json" \
  -d '{
    "port": 8642,
    "allowedIPs": ["127.0.0.1"]
  }'
```

## API Reference

### POST /api/notify

Send a notification to the system.

**Request Body:**
```json
{
  "title": "string (required)",
  "body": "string (required)",
  "icon": "string (optional)",
  "priority": "low|normal|high (optional, default: normal)",
  "category": "string (optional, use 'flash' for screen flash)",
  "flashColor": "string (optional, for flash category, default: #FF0000)",
  "flashDuration": "int (optional, for flash category, default: 500)",
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
  "autoStart": true,
  "showNotifications": true
}
```

## Documentation

- [Project Plan](plan.md) - Detailed project plan and architecture
- [Progress Report](progress.md) - Implementation status and next steps
- [Flash Screen Feature](flash-screen.md) - Flash screen overlay documentation
- [Build and Test Guide](build_and_test.md) - Building and testing instructions

## Technology Stack

- **Framework**: Flutter 3.10.7+
- **HTTP Server**: shelf
- **Local Notifications**: flutter_local_notifications
- **State Management**: provider
- **Persistence**: shared_preferences
- **System Tray**: system_tray

## Development

### Run Analysis

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

### Build for Release

```bash
# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Windows
flutter build windows --release
```

## License

MIT

## Status

**Version**: 0.1.0
**Status**: Development Phase - Core features implemented, testing in progress

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
