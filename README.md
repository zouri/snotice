# SNotice

A cross-platform desktop notification webhook application for macOS, Linux, and Windows.

## Features

- 📢 **System Notifications**: Send notifications via HTTP API
- 🌐 **HTTP Webhook**: RESTful API endpoint for sending notifications
- ⚙️ **Configurable UI**: Service status and network settings
- 📋 **System Tray**: Service control and window actions
- 🔒 **IP Whitelist**: Simple IP-based access control
- 🎨 **Flash Screen**: Full-screen overlay notifications with custom colors
- 📺 **Barrage Overlay**: Right-to-left scrolling text overlay reminders
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
    "category": "flash_full",
    "flashColor": "gray",
    "flashDuration": 100
  }'
```

### Edge Flash Notification

```bash
curl -X POST http://localhost:8642/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Edge Alert",
    "category": "flash_edge",
    "flashColor": "#00D1FF",
    "flashDuration": 700,
    "edgeWidth": 12,
    "edgeOpacity": 0.92,
    "edgeRepeat": 2
  }'
```

### Barrage Notification

```bash
curl -X POST http://localhost:8642/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Barrage Alert",
    "body": "Build passed",
    "category": "barrage",
    "barrageColor": "#FFD84D",
    "barrageDuration": 6000,
    "barrageSpeed": 160,
    "barrageFontSize": 30,
    "barrageLane": "top"
  }'
```

### Test API with Python Script

You can use `scripts/test_http_api.py` to quickly test all HTTP endpoints.

```bash
# Show usage
python3 scripts/test_http_api.py --help

# Check server status
python3 scripts/test_http_api.py status

# Send a normal notification
python3 scripts/test_http_api.py notify --mode normal

# Send a full-screen flash notification
python3 scripts/test_http_api.py notify --mode flash_full --flash-color "#FF0000"

# Send an edge-lighting notification
python3 scripts/test_http_api.py notify --mode flash_edge --flash-color "#00D1FF"

# Send a barrage overlay notification
python3 scripts/test_http_api.py notify --mode barrage --body "Deploy finished"

# Run smoke test (status + normal notify + edge notify)
python3 scripts/test_http_api.py smoke --include-edge
```

Supported `notify --mode` values:

- `normal`
- `flash_full`
- `flash_edge`
- `barrage`

Request notes:

- `body` is required for normal notifications, and optional for `flash_full`, `flash_edge`, and `barrage`.
- `edgeWidth` / `edgeOpacity` / `edgeRepeat` are valid only when `category=flash_edge`.
- `barrageColor` / `barrageDuration` / `barrageSpeed` / `barrageFontSize` /
  `barrageLane` / `barrageRepeat` are valid only when `category=barrage`.
- `barrageRepeat` range is `1..8`.

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
python3 skills/snotice-agent/scripts/snotice_call.py config-get
python3 skills/snotice-agent/scripts/snotice_call.py notify --title "Build Done" --body "Release package finished"
```

## Documentation

For detailed documentation, see the [docs](./docs) directory:

- [Docs Index](./docs/README.md) - documentation entry and maintenance guide
- [Architecture](./docs/architecture.md) - runtime architecture and module flows
- [AI Agent Integration](./docs/agent_integration.md) - MCP and skill setup

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
