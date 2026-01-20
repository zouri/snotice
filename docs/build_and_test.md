# SNotice 构建和测试指南

## 环境要求

- Flutter SDK 3.10.7 或更高版本
- macOS 10.15+ / Ubuntu 20.04+ / Windows 10+
- 系统开发工具（Xcode for macOS, Visual Studio for Windows, etc.）

## 快速开始

### 1. 安装依赖

```bash
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
flutter pub get
```

### 2. 代码检查

```bash
flutter analyze
```

### 3. 运行应用

```bash
# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

## 测试步骤

### 基础功能测试

1. **启动应用**
   - 打开应用
   - 检查主界面是否正常显示
   - 检查系统托盘图标是否出现

2. **启动服务器**
   - 点击 "Start Server" 按钮
   - 检查状态是否变为 "Server Running"
   - 检查端口显示是否正确（默认 8080）

3. **发送测试通知**
   - 进入 "Test" 页面
   - 选择预设或手动输入通知内容
   - 点击 "Send Notification"
   - 检查系统通知是否正常显示

### API 测试

在服务器运行后，使用以下命令测试 API：

#### 测试发送通知

```bash
curl -X POST http://localhost:8080/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "API 测试",
    "body": "这是一条通过 API 发送的通知",
    "priority": "high"
  }'
```

预期响应：
```json
{
  "success": true,
  "message": "Notification sent",
  "timestamp": "2026-01-13T10:30:00.000Z"
}
```

#### 测试获取状态

```bash
curl http://localhost:8080/api/status
```

预期响应：
```json
{
  "running": true,
  "port": 8080,
  "uptime": <运行秒数>
}
```

#### 测试获取配置

```bash
curl http://localhost:8080/api/config
```

预期响应：
```json
{
  "port": 8080,
  "allowedIPs": ["127.0.0.1", "::1"],
  "autoStart": true,
  "showNotifications": true
}
```

#### 测试更新配置

```bash
curl -X POST http://localhost:8080/api/config \
  -H "Content-Type: application/json" \
  -d '{
    "port": 8080,
    "allowedIPs": ["127.0.0.1"],
    "autoStart": false
  }'
```

### 配置测试

1. **修改端口**
   - 进入 "Settings" 页面
   - 修改端口为 8081
   - 保存设置
   - 重启服务器
   - 使用新端口测试 API

2. **IP 白名单测试**
   - 进入 "Settings" 页面
   - 添加一个不存在的 IP（如 192.168.1.100）
   - 保存设置
   - 从该 IP（如果可能）发送请求应该被拒绝
   - 清空白名单后应该允许所有请求

3. **自动启动测试**
   - 启用 "Auto Start"
   - 保存设置
   - 重启应用
   - 检查服务器是否自动启动

### 日志测试

1. **查看日志**
   - 进入 "Logs" 页面
   - 检查是否显示所有类型的日志

2. **筛选日志**
   - 点击筛选按钮
   - 选择 "Requests"
   - 检查是否只显示请求日志
   - 选择 "Notifications"
   - 检查是否只显示通知日志

3. **清除日志**
   - 点击清除按钮
   - 确认清除
   - 检查日志是否被清空

## 构建发布版本

### macOS

```bash
flutter build macos --release
```

输出文件：`build/macos/Build/Products/Release/snotice_new.app`

创建 DMG（可选）：
```bash
# 安装 create-dmg 工具
brew install create-dmg

# 创建 DMG 文件
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

输出目录：`build/linux/x64/release/bundle/`

创建 DEB 包（可选）：
```bash
# 使用 linuxdeploy
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage

# 创建 AppImage
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

输出目录：`build\windows\runner\Release\`

使用 Inno Setup 创建安装包（可选）：
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

## 常见问题

### Q: 应用无法启动
A: 确保已安装所有依赖并运行 `flutter pub get`

### Q: HTTP 服务器无法启动
A: 检查端口是否被占用，尝试更换端口

### Q: 通知无法显示
A: 检查系统通知权限，确保应用有权限显示通知

### Q: IP 白名单不工作
A: 确保输入的 IP 地址格式正确（如 127.0.0.1）

### Q: 构建失败
A: 确保已安装平台特定的开发工具：
- macOS: Xcode
- Linux: GTK+3.0 开发库
- Windows: Visual Studio 2019 或更高版本

## 性能优化建议

1. **日志轮转**：当前日志在内存中，考虑添加磁盘持久化和轮转
2. **连接池**：HTTP 服务器可以使用连接池优化性能
3. **异步处理**：确保所有 I/O 操作都是异步的
4. **资源清理**：确保在应用退出时正确清理资源

## 安全建议

1. **使用 HTTPS**：在生产环境中考虑使用 HTTPS
2. **更强的认证**：考虑添加 API 密钥或 OAuth
3. **输入验证**：确保所有输入都经过严格验证
4. **日志脱敏**：不要在日志中记录敏感信息

## 下一步

1. 完成所有基础功能测试
2. 在目标平台上构建和测试
3. 修复发现的问题
4. 准备发布文档和安装包
5. 创建用户指南

## 支持

如有问题，请查看：
- [Project Plan](plan.md)
- [Progress Report](progress.md)
- [Flutter Documentation](https://docs.flutter.dev/)
