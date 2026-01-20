# 闪烁功能 - 快速开始

## 🚀 一键测试

```bash
# 1. 启动应用
flutter run -d macos

# 2. 在应用中启动服务器

# 3. 发送测试
curl -X POST http://localhost:8080/api/notify \
  -d '{"title":"Test","body":"Flash","category":"flash","flashColor":"gray","flashDuration":800}'
```

## 📋 核心配置

### 窗口属性
- **全屏**: ✅ `setFullScreen(true)`
- **置顶**: ✅ `setAlwaysOnTop(true)`
- **透明度**: ✅ `setOpacity(0.5)` (50%)
- **跳过任务栏**: ✅ `setSkipTaskbar(true)`

### 动画流程
```
淡入 (0% → 80%) → 保持 → 淡出 (80% → 0%) → 关闭
```

## 🎨 常用命令

### 红色紧急
```bash
curl -X POST http://localhost:8080/api/notify \
  -d '{"title":"Alert","body":"Flash","category":"flash","flashColor":"#FF0000"}'
```

### 灰色温和（推荐）
```bash
curl -X POST http://localhost:8080/api/notify \
  -d '{"title":"Notification","body":"Flash","category":"flash","flashColor":"gray","flashDuration":800}'
```

### 黄色警告
```bash
curl -X POST http://localhost:8080/api/notify \
  -d '{"title":"Warning","body":"Flash","category":"flash","flashColor":"yellow","flashDuration":1000}'
```

## 📁 关键文件

| 文件 | 作用 | 行数 |
|------|------|------|
| `lib/overlay_main.dart` | 窗口入口+配置 | 200 |
| `lib/services/flash_overlay_service.dart` | 闪烁服务 | 64 |
| `lib/services/notification_service.dart` | 通知处理 | 修改 |
| `lib/ui/test_screen.dart` | 测试界面 | 修改 |

## 🔧 关键代码位置

### 窗口配置
```dart
// lib/overlay_main.dart:52-57
await windowManager.setOpacity(0.5);      // 50% 透明度
await windowManager.setAlwaysOnTop(true); // 置顶
await windowManager.setFullScreen(true);  // 全屏
```

### 闪烁触发
```dart
// lib/services/flash_overlay_service.dart:38-46
await controller.invokeMethod('setOpacity', 0.5);
await controller.invokeMethod('setAlwaysOnTop', true);
await controller.invokeMethod('setFullScreen', true);
```

## ✅ 检查清单

- [ ] `flutter pub get`
- [ ] `flutter run -d macos`
- [ ] 启动服务器
- [ ] 发送测试
- [ ] 观察效果

---

**状态**: ✅ 完成
**透明度**: 50%
**覆盖**: 全屏+置顶
