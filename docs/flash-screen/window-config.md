# 全屏覆盖窗口配置说明

## 🎯 当前实现

### 窗口配置（overlay_main.dart）

```dart
Future<void> _configureOverlayWindow() async {
  const windowOptions = WindowOptions(
    size: Size(1920, 1080),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();

    // 关键配置
    await windowManager.setOpacity(0.5);        // 50% 透明度
    await windowManager.setSkipTaskbar(true);   // 隐藏任务栏
    await windowManager.setAlwaysOnTop(true);   // 置顶显示
    await windowManager.setFullScreen(true);    // 全屏模式
  });
}
```

### 闪烁服务配置（flash_overlay_service.dart）

```dart
// 创建窗口后配置
await controller.invokeMethod('setOpacity', 0.5);        // 50% 透明度
await controller.invokeMethod('setSkipTaskbar', true);   // 隐藏任务栏
await controller.invokeMethod('setAlwaysOnTop', true);   // 置顶显示
await controller.invokeMethod('setFullScreen', true);    // 全屏模式
await controller.invokeMethod('setTransparent', true);   // 透明背景
```

## 🔧 关键属性说明

### 1. 透明度 (Opacity)
- **值**: 0.5 (50%)
- **作用**: 让覆盖窗口半透明，可以看到底层内容
- **设置位置**:
  - `overlay_main.dart`: `windowManager.setOpacity(0.5)`
  - `flash_overlay_service.dart`: `controller.invokeMethod('setOpacity', 0.5)`

### 2. 全屏 (Full Screen)
- **值**: true
- **作用**: 覆盖整个屏幕
- **设置位置**: `windowManager.setFullScreen(true)`

### 3. 置顶 (Always On Top)
- **值**: true
- **作用**: 窗口始终在最上层，覆盖其他应用
- **设置位置**: `windowManager.setAlwaysOnTop(true)`

### 4. 跳过任务栏 (Skip Taskbar)
- **值**: true
- **作用**: 不在任务栏显示，避免用户误点
- **设置位置**: `windowManager.setSkipTaskbar(true)`

### 5. 透明背景 (Transparent)
- **值**: true
- **作用**: 窗口背景透明，只显示闪烁颜色
- **设置位置**: `controller.invokeMethod('setTransparent', true)`

## 📊 窗口层级架构

```
用户桌面
    ↓
其他应用窗口
    ↓
覆盖窗口 (置顶, 全屏, 50%透明)
    ↓
闪烁动画层 (根据透明度显示颜色)
```

## 🎨 闪烁效果流程

1. **窗口创建**: 创建全屏透明窗口
2. **配置属性**: 设置 50% 透明度、置顶、全屏
3. **显示窗口**: 显示并聚焦
4. **动画开始**:
   - 淡入: 0% → 80% 颜色透明度（在 50% 窗口透明度基础上）
   - 保持: 持续指定时间
   - 淡出: 80% → 0% 颜色透明度
5. **自动关闭**: 动画结束，关闭窗口

## 🔍 透明度叠加说明

```
窗口透明度: 50% (0.5)
    ↓
颜色透明度动画: 0% → 80% → 0%
    ↓
最终效果: 50% × 颜色透明度
```

例如：
- 红色闪烁，颜色透明度 80% → 最终显示: 50% 红色
- 灰色蒙版，颜色透明度 80% → 最终显示: 50% 灰色

## ⚙️ 可调整参数

### 在 overlay_main.dart 中调整
```dart
// 透明度 (0.0 - 1.0)
await windowManager.setOpacity(0.5);  // 50%

// 全屏
await windowManager.setFullScreen(true);
```

### 在 FlashOverlayScreen 中调整
```dart
// 颜色最大透明度
_opacityAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(...);
```

## 🐛 常见问题

### 问题 1: 窗口不覆盖全屏
**原因**: `setFullScreen(true)` 未生效
**解决**:
1. 确保 `windowManager.ensureInitialized()` 已调用
2. 在 `waitUntilReadyToShow` 回调中设置
3. 检查平台是否支持全屏

### 问题 2: 窗口不置顶
**原因**: `setAlwaysOnTop(true)` 未生效
**解决**:
1. 确保在显示窗口后调用
2. 检查平台权限
3. 尝试在 `WindowOptions` 中设置 `alwaysOnTop: true`

### 问题 3: 透明度不正确
**原因**: 多个透明度设置冲突
**解决**:
- 窗口透明度: 0.5 (50%)
- 颜色透明度: 0.0 → 0.8 → 0.0
- 最终效果: 50% × 颜色透明度

## 📝 测试验证

### 验证步骤
1. 启动应用
2. 发送闪烁通知
3. 观察：
   - ✅ 是否覆盖整个屏幕
   - ✅ 是否覆盖其他应用（包括全屏应用）
   - ✅ 是否置顶显示
   - ✅ 是否半透明（50%）
   - ✅ 颜色是否正确
   - ✅ 动画是否平滑

### 预期效果
```
屏幕状态: 全屏覆盖
窗口层级: 最顶层
透明度: 50% (可看到底层内容)
颜色: 指定颜色（如灰色）
动画: 淡入 → 保持 → 淡出
```

## 🔗 相关文件

- `lib/overlay_main.dart` - 窗口配置和入口
- `lib/services/flash_overlay_service.dart` - 窗口创建和配置
- `lib/overlay_main.dart:35-59` - `_configureOverlayWindow()` 函数

---

**配置状态**: ✅ 已完成
**透明度**: 50%
**覆盖范围**: 全屏
**置顶**: 是
