# Documentation Index

Welcome to SNotice documentation. This index helps you find the information you need.

## Quick Links

- [Getting Started](./README.md) - Quick start guide
- [Flash Screen Notifications](./flash-screen/implementation.md) - Flash screen feature
- [Build and Test](./build_and_test.md) - Building and testing
- [API Reference](./README.md#api-reference) - Complete API documentation

## Documentation Structure

### User Documentation

- [Full README](./README.md)
  - Project overview
  - Installation
  - API usage
  - API reference
  - Technology stack

### Feature Documentation

- [Flash Screen Notifications](./flash-screen/implementation.md)
  - Feature overview
  - Quick start
  - API parameters
  - Supported colors
  - Recommended configurations
  - Troubleshooting

- [Flash Screen Quick Start](./flash-screen/quick-start.md)
  - One-command testing
  - Core configuration
  - Common commands
  - Key files
  - Checklist

- [Flash Screen Window Configuration](./flash-screen/window-config.md)
  - Window configuration details
  - Key properties
  - Window hierarchy
  - Animation flow
  - Transparency settings

### Development Documentation

- [Build and Test Guide](./build_and_test.md)
  - Environment requirements
  - Testing procedures
  - Building for release
  - Common issues
  - Performance optimization

- [Project Plan](./plan.md)
  - Project overview
  - Technical stack
  - Implementation steps
  - API interface details
  - Data models

- [Progress Report](./progress.md)
  - Completed work
  - Code quality
  - Remaining tasks
  - Next steps

### AI Assistant Documentation

- [AGENTS.md](./AGENTS.md)
  - Build, lint, and test commands
  - Code style guidelines
  - Project structure
  - Testing guidelines

- [CLAUDE.md](./CLAUDE.md)
  - Project overview
  - Development commands
  - Architecture
  - Key implementation details
  - Platform-specific notes

## Navigation

### For New Users
1. Start with [Full README](./README.md)
2. Try the [Quick Start](./README.md#quick-start) examples
3. Explore [Flash Screen](./flash-screen/implementation.md) for advanced features

### For Developers
1. Review [Project Plan](./plan.md) for architecture
2. Check [Progress Report](./progress.md) for current status
3. Follow [Build and Test Guide](./build_and_test.md) for development

### For AI Assistants
1. Read [AGENTS.md](./AGENTS.md) for coding guidelines
2. Check [CLAUDE.md](./CLAUDE.md) for project context
3. Refer to [Plan](./plan.md) for implementation details

## API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/notify` | Send system or flash notification |
| GET | `/api/status` | Server status and uptime |
| GET | `/api/config` | Current configuration |
| POST | `/api/config` | Update configuration |

## Quick Commands

```bash
# Install dependencies
flutter pub get

# Run analysis
flutter analyze

# Run on macOS
flutter run -d macos

# Build for release
flutter build macos --release

# Test API
curl -X POST http://localhost:8080/api/notify \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","body":"Notification"}'
```

## Support

For issues or questions:
- Check the [troubleshooting sections](./build_and_test.md#常见问题)
- Review [implementation details](./plan.md)
- Check [progress report](./progress.md) for known issues
