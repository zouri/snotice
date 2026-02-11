# SNotice Build and Test Guide

## Environment Requirements

- Flutter SDK 3.10.7 or higher
- macOS 10.15+ / Ubuntu 20.04+ / Windows 10+
- System development tools (Xcode for macOS, Visual Studio for Windows, etc.)

## Quick Start

### 1. Install Dependencies

```bash
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
flutter pub get
```

### 2. Code Analysis

```bash
flutter analyze
```

### 3. Run Application

```bash
# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

## Testing Steps

### Basic Functionality Testing

1. **Start Application**
   - Launch the app
   - Verify main screen displays correctly
   - Check system tray icon appears

2. **Start Server**
   - Click "Start Server" button
   - Verify status changes to "Server Running"
   - Verify port displays correctly (default 8642)

3. **Send Test Notification**
   - Go to "Test" page
   - Select preset or enter notification content manually
   - Click "Send Notification"
   - Verify system notification displays correctly

### API Testing

Test the API while the server is running:

#### Test Sending Notification

```bash
curl -X POST http://localhost:8642/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "API Test",
    "body": "This is a notification sent via API",
    "priority": "high"
  }'
```

Expected Response:
```json
{
  "success": true,
  "message": "Notification sent",
  "timestamp": "2026-01-13T10:30:00.000Z"
}
```

#### Test Getting Status

```bash
curl http://localhost:8642/api/status
```

Expected Response:
```json
{
  "running": true,
  "port": 8642,
  "uptime": <seconds_running>
}
```

#### Test Getting Configuration

```bash
curl http://localhost:8642/api/config
```

Expected Response:
```json
{
  "port": 8642,
  "allowedIPs": ["127.0.0.1", "::1"],
  "autoStart": true,
  "showNotifications": true
}
```

#### Test Updating Configuration

```bash
curl -X POST http://localhost:8642/api/config \
  -H "Content-Type: application/json" \
  -d '{
    "port": 8642,
    "allowedIPs": ["127.0.0.1"],
    "autoStart": false
  }'
```

### Configuration Testing

1. **Change Port**
   - Go to "Settings" page
   - Change port to 8081
   - Save settings
   - Restart server
   - Test API with new port

2. **IP Whitelist Testing**
   - Go to "Settings" page
   - Add a non-existent IP (e.g., 192.168.1.100)
   - Save settings
   - Requests from that IP should be rejected (if possible)
   - Clear whitelist to allow all requests

3. **Auto Start Testing**
   - Enable "Auto Start"
   - Save settings
   - Restart application
   - Verify server starts automatically

### Log Testing

1. **View Logs**
   - Go to "Logs" page
   - Verify all log types are displayed

2. **Filter Logs**
   - Click filter button
   - Select "Requests"
   - Verify only request logs are shown
   - Select "Notifications"
   - Verify only notification logs are shown

3. **Clear Logs**
   - Click clear button
   - Confirm clear
   - Verify logs are cleared

### Flash Screen Testing

1. **Via UI**
   - Go to "Test" page
   - Select Category: "Flash (Screen)"
   - Choose a color
   - Set duration
   - Click "Send Notification"
   - Verify full-screen flash appears

2. **Via API**
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
   - Verify full-screen overlay appears
   - Verify it covers all applications
   - Verify overlay is semi-transparent
   - Verify overlay closes automatically

## Building Release Versions

### macOS

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/snotice_new.app`

Create DMG (optional):
```bash
# Install create-dmg tool
brew install create-dmg

# Create DMG file
create-dmg \
  --volname "SNotice" \
  --volicon "assets/icons/app_icon.icns" \
  --window-pos 200 120 \
  --window-size 600 300 \
  --icon-size 100 \
  --app-drop-link 600 185 \
  "SNotice-0.1.0.dmg" \
  "build/macos/Build/Products/Release/snotice_new.app"
```

### Linux

```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

Create DEB package (optional):
```bash
# Use linuxdeploy
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage

# Create AppImage
./linuxdeploy-x86_64.AppImage \
  --appdir SNotice.AppDir \
  --executable build/linux/x64/release/bundle/snotice_new \
  --icon-file assets/icons/app_icon.png \
  --output appimage/SNotice-0.1.0.AppImage
```

### Windows

```bash
flutter build windows --release
```

Output: `build\windows\runner\Release\`

Create installer using Inno Setup (optional):
```iss
[Setup]
AppName=SNotice
AppVersion=0.1.0
DefaultDirName={pf}\SNotice
OutputBaseFilename=SNotice-0.1.0-setup

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{userdesktop}\SNotice"; Filename: "{app}\snotice_new.exe"
```

## Common Issues

### Q: Application won't start
A: Ensure all dependencies are installed by running `flutter pub get`

### Q: HTTP server won't start
A: Check if the port is already in use, try changing the port

### Q: Notifications not displaying
A: Check system notification permissions, ensure app has permission to display notifications

### Q: IP whitelist not working
A: Ensure IP address format is correct (e.g., 127.0.0.1)

### Q: Build fails
A: Ensure platform-specific development tools are installed:
- macOS: Xcode
- Linux: GTK+3.0 development libraries
- Windows: Visual Studio 2019 or higher

### Q: Flash screen overlay not appearing
A: Ensure `category` is set to `"flash"` in the API request and check desktop_multi_window plugin is properly installed

## Performance Optimization Suggestions

1. **Log Rotation**: Current logs are in-memory, consider adding disk persistence and rotation
2. **Connection Pooling**: HTTP server can use connection pooling for performance
3. **Async Processing**: Ensure all I/O operations are async
4. **Resource Cleanup**: Ensure resources are properly cleaned up when app exits

## Security Suggestions

1. **Use HTTPS**: Consider using HTTPS in production environments
2. **Stronger Authentication**: Consider adding API keys or OAuth
3. **Input Validation**: Ensure all inputs are strictly validated
4. **Log Sanitization**: Don't log sensitive information

## Next Steps

1. Complete all basic functionality testing
2. Build and test on target platforms
3. Fix any discovered issues
4. Prepare release documentation and installers
5. Create user guide

## Support

For issues or questions:
- Check the [Project Plan](plan.md)
- Review the [Progress Report](progress.md)
- Refer to [Flutter Documentation](https://docs.flutter.dev/)
- Check [Flash Screen Documentation](flash-screen.md)
