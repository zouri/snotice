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

### Test API with Python Script

You can use `scripts/test_http_api.py` to quickly test all HTTP endpoints.

```bash
# Show usage
python3 scripts/test_http_api.py --help

# Check server status
python3 scripts/test_http_api.py status

# Get current config
python3 scripts/test_http_api.py config-get

# Send a normal notification
python3 scripts/test_http_api.py notify --mode normal

# Send an edge-lighting notification (macOS)
python3 scripts/test_http_api.py notify --mode edge_rainbow --flash-color "#00D1FF"

# Run smoke test (status + normal notify + edge notify)
python3 scripts/test_http_api.py smoke --include-edge --edge-effect edge_dual
```

Supported `notify --mode` values:

- `normal`
- `flash`
- `edge`
- `edge_pulse`
- `edge_dual`
- `edge_dash`
- `edge_corner`
- `edge_rainbow`

## Documentation

For detailed documentation, see the [docs](./docs) directory:

- [Full Documentation](./docs/README.md) - Complete project documentation
- [Project Plan](./docs/plan.md) - Detailed project plan and architecture
- [Progress Report](./docs/progress.md) - Implementation status
- [Build and Test Guide](./docs/build_and_test.md) - Building and testing instructions
- [Flash Screen Feature](./docs/flash-screen.md) - Flash screen overlay documentation

## Technology Stack

- **Framework**: Flutter 3.10.7+
- **HTTP Server**: shelf
- **Local Notifications**: flutter_local_notifications
- **State Management**: provider
- **Persistence**: shared_preferences
- **System Tray**: system_tray
- **Multi-window**: desktop_multi_window
- **Window Management**: window_manager

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
