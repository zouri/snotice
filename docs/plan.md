# SNotice - 跨平台通知 Webhook 应用

## 项目概述

SNotice 是一个运行在 macOS、Ubuntu (Linux) 和 Windows 上的桌面应用，通过 HTTP API 提供系统通知功能，相当于一个通知 Webhook。

## 核心功能

- **跨平台支持**: macOS、Linux、Windows
- **HTTP API**: RESTful 接口发送系统通知
- **富文本通知**: 支持标题、内容、图标、优先级、分类等参数
- **配置界面**: 可配置端口、IP 白名单等
- **日志记录**: 记录通知历史和 HTTP 请求
- **系统托盘**: 最小化托盘，右键菜单控制
- **IP 白名单**: 简单的 IP 限制验证

## 技术栈

- **框架**: Flutter 3.10.7+
- **HTTP 服务器**: shelf
- **本地通知**: flutter_local_notifications
- **系统托盘**: system_tray
- **状态管理**: provider
- **配置持久化**: shared_preferences
- **日志**: logger

## 项目结构

```
lib/
├── main.dart                          # 应用入口
├── config/
│   └── constants.dart                  # 常量定义
├── models/
│   ├── notification_request.dart      # 通知请求模型
│   ├── app_config.dart                # 应用配置模型
│   └── log_entry.dart                 # 日志条目模型
├── services/
│   ├── http_server_service.dart       # HTTP 服务
│   ├── notification_service.dart      # 通知服务
│   ├── tray_service.dart              # 托盘服务
│   ├── config_service.dart           # 配置服务
│   └── logger_service.dart           # 日志服务
├── providers/
│   ├── config_provider.dart          # 配置状态管理
│   ├── log_provider.dart             # 日志状态管理
│   └── server_provider.dart          # 服务器状态管理
├── ui/
│   ├── main_screen.dart              # 主界面
│   ├── settings_screen.dart          # 设置界面
│   ├── log_screen.dart               # 日志界面
│   └── test_screen.dart              # 测试界面
└── utils/
    └── response_util.dart            # 响应工具类
```

## API 接口

### 发送通知

```http
POST /api/notify
Content-Type: application/json

{
  "title": "通知标题",
  "body": "通知内容",
  "icon": "path/to/icon.png",
  "priority": "high",
  "category": "alert"
}
```

**响应:**
```json
{
  "success": true,
  "message": "通知已发送",
  "timestamp": "2026-01-13T10:30:00.000Z"
}
```

### 获取服务状态

```http
GET /api/status
```

**响应:**
```json
{
  "running": true,
  "port": 8080,
  "uptime": 3600
}
```

### 获取配置

```http
GET /api/config
```

**响应:**
```json
{
  "port": 8080,
  "allowedIPs": ["127.0.0.1", "::1"],
  "autoStart": true,
  "showNotifications": true
}
```

### 更新配置

```http
POST /api/config
Content-Type: application/json

{
  "port": 8080,
  "allowedIPs": ["127.0.0.1"],
  "autoStart": false
}
```

## 数据模型

### NotificationRequest

```dart
class NotificationRequest {
  String title;
  String body;
  String? icon;
  String? priority; // low, normal, high
  String? category;
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

## 实施步骤

### 第一步：更新依赖包

在 `pubspec.yaml` 添加以下依赖：

```yaml
dependencies:
  shelf: ^1.4.1
  shelf_router: ^1.1.4
  flutter_local_notifications: ^17.0.0
  system_tray: ^2.0.3
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  logger: ^2.0.2+1
  convert: ^3.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

### 第二步：创建目录结构

创建所有必要的目录和空文件。

### 第三步：实现核心服务

**1. 配置服务** (`config_service.dart`)
- 加载/保存配置
- 默认配置管理
- 使用 shared_preferences 持久化

**2. HTTP 服务** (`http_server_service.dart`)
- 使用 shelf 实现 HTTP 服务器
- 端点实现
- IP 白名单验证

**3. 通知服务** (`notification_service.dart`)
- 初始化各平台通知
- 支持富文本参数
- 处理平台差异

**4. 系统托盘服务** (`tray_service.dart`)
- 托盘图标管理
- 右键菜单

**5. 日志服务** (`logger_service.dart`)
- 记录 HTTP 请求
- 记录通知发送历史
- 日志级别管理

### 第四步：实现数据模型

创建所有数据模型类。

### 第五步：实现状态管理

创建 provider 类管理应用状态。

### 第六步：实现 UI 界面

创建所有 UI 界面。

### 第七步：平台特定配置

**macOS** (`macos/Runner/Release.entitlements`)
```xml
<key>com.apple.security.network.server</key>
<true/>
```

### 第八步：主程序入口

实现 `main.dart` 初始化所有服务。

### 第九步：测试和优化

- 测试各平台通知功能
- 测试 HTTP API 端点
- 测试配置持久化
- 优化性能和内存使用

## 使用示例

### cURL 示例

```bash
curl -X POST http://localhost:8080/api/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "测试通知",
    "body": "这是一条来自 SNotice 的通知",
    "priority": "high"
  }'
```

### JavaScript 示例

```javascript
fetch('http://localhost:8080/api/notify', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    title: '通知标题',
    body: '通知内容',
    priority: 'normal'
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

## 安全性

- **IP 白名单**: 默认只允许 localhost 访问
- **端口可配置**: 避免端口冲突
- **输入验证**: 验证所有输入参数

## 性能考虑

- 异步处理通知发送
- 日志轮转避免内存溢出
- HTTP 连接池复用

## 许可证

MIT

## 作者

SNotice Team
