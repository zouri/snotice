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
curl -X POST http://localhost:8080/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Hello",
    "body": "This is a notification",
    "priority": "high"
  }'
```

### Flash Screen Notification

```bash
curl -X POST http://localhost:8080/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Alert",
    "body": "Screen flash",
    "category": "flash",
    "flashColor": "gray",
    "flashDuration": 800
  }'
```

## Documentation

For detailed documentation, see the [docs](./docs) directory:

- [Full README](./docs/README.md) - Complete project documentation
- [Flash Screen Feature](./docs/flash-screen/implementation.md) - Flash screen notifications
- [Build and Test](./docs/build_and_test.md) - Building and testing guide
- [Project Plan](./docs/plan.md) - Detailed project plan
- [Progress Report](./docs/progress.md) - Implementation status

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
