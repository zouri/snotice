# SNotice

A cross-platform desktop notification webhook application for macOS, Linux, and Windows.

## Features

- 📢 **System Notifications**: Send notifications via HTTP API
- 🌐 **HTTP Webhook**: RESTful API endpoint for sending notifications
- ⚙️ **Configurable UI**: Service status and network settings
- 📋 **System Tray**: Service control and window actions
- 🔒 **IP Whitelist**: Simple IP-based access control
- 🎨 **Flash Screen**: Full-screen overlay notifications with custom colors
- 🎯 **Focused Scope**: No built-in reminder scheduling or template creation

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

### Check Server Status

```bash
curl http://localhost:8642/api/status
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

## AI Agent Integration

SNotice can be called by AI agents in two ways: MCP tools or skill scripts.

### 1) Built-in MCP Endpoint

MCP is integrated directly into the SNotice HTTP server.

Endpoint:

- `POST /api/mcp` (default URL: `http://127.0.0.1:8642/api/mcp`)

Exposed MCP tools:

- `snotice_send_notification`
- `snotice_get_status`
- `snotice_get_config`
- `snotice_update_config`

Quick probe:

```bash
curl -X POST http://127.0.0.1:8642/api/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

### 2) Skill-Based Calls

This repo includes a reusable skill at:

- `skills/snotice-agent/SKILL.md`

The skill provides:

- a CLI helper script: `skills/snotice-agent/scripts/snotice_call.py`
- API field references: `skills/snotice-agent/references/*.md`

Quick command examples:

```bash
python3 skills/snotice-agent/scripts/snotice_call.py status
python3 skills/snotice-agent/scripts/snotice_call.py notify --title "Build Done" --body "Release package finished"
```

## Documentation

For detailed documentation, see the [docs](./docs) directory:

- [AI Agent Integration](./docs/agent_integration.md) - MCP and skill setup
- [Enhancement Notes](./docs/enhance/README.md) - UI and architecture enhancements
- [UX Improvements](./docs/enhance/UX_IMPROVEMENTS.md) - UX implementation details
- [Project Status](./docs/enhance/PROJECT_STATUS.md) - Current status snapshot

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
