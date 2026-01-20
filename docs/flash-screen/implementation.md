# 闪烁屏幕通知功能

## 功能概述

SNotice 支持全屏闪烁通知，可在任何应用（包括全屏应用）上方显示透明蒙版闪烁效果，用于紧急提醒。

## 快速开始

### 通过 TestScreen 测试
1. 启动应用：`flutter run -d macos`
2. 点击右上角 "Test" 按钮
3. 选择 Category: **Flash (Screen)**
4. 选择颜色（点击颜色按钮）
5. 设置持续时间（默认 500ms）
6. 点击 "Send Notification"
7. 观察全屏闪烁效果

### 通过 HTTP API

```bash
# 红色闪烁
curl -X POST http://localhost:8080/api/notify \
  -H "Content-Type: application/json" \
  -d '{"title":"Alert","body":"Check screen","category":"flash","flashColor":"#FF0000"}'

# 灰色蒙版（推荐）
curl -X POST http://localhost:8080/api/notify \
  -H "Content-Type: application/json" \
  -d '{"title":"Notification","body":"Screen flash","category":"flash","flashColor":"gray","flashDuration":800}'

# 黄色闪烁，1秒
curl -X POST http://localhost:8080/api/notify \
  -H "Content-Type: application/json" \
  -d '{"title":"Warning","body":"Attention","category":"flash","flashColor":"yellow","flashDuration":1000}'
```

## API 参数

```json
{
  "title": "string (required)",
  "body": "string (required)",
  "category": "flash",
  "flashColor": "string (optional, default: #FF0000)",
  "flashDuration": "int (optional, default: 500)"
}
```

### 参数说明
- `category`: 必须设置为 `"flash"` 才能触发屏幕闪烁
- `flashColor`: 闪烁颜色
  - 十六进制: `"#FF0000"`, `"0xFFFF0000"`
  - 颜色名称: `"red"`, `"blue"`, `"green"`, `"yellow"`, `"white"`, `"gray"`, `"orange"`, `"purple"`, `"pink"`, `"cyan"`
- `flashDuration`: 闪烁持续时间（毫秒），默认 500ms

## 支持的颜色

### 十六进制格式
- `#FF0000` - 红色
- `#00FF00` - 绿色
- `#0000FF` - 蓝色
- `#FFFFFF` - 白色
- `#808080` - 灰色
- `#FFA500` - 橙色

### 颜色名称
- `red`, `blue`, `green`, `yellow`
- `white`, `black`, `gray` (或 `grey`)
- `orange`, `purple`, `pink`, `cyan`

## 推荐配置

### 紧急通知
```json
{
  "flashColor": "#FF0000",
  "flashDuration": 500
}
```

### 温和提醒
```json
{
  "flashColor": "gray",
  "flashDuration": 800
}
```

### 警告提示
```json
{
  "flashColor": "yellow",
  "flashDuration": 1000
}
```

## 技术实现

### 架构流程
```
主应用 (SNotice)
    ↓ HTTP API 请求
NotificationService
    ↓ 检测 category == 'flash'
FlashOverlayService
    ↓ 创建覆盖窗口
DesktopMultiWindow 插件
    ↓ 创建独立窗口
overlay_main.dart (覆盖窗口入口)
    ↓ 显示闪烁动画
FlashOverlayScreen
```

### 技术栈
- `desktop_multi_window` - 多窗口创建
- `window_manager` - 窗口管理
- `provider` - 状态管理

### 核心文件
- `lib/overlay_main.dart` - 覆盖窗口入口
- `lib/services/flash_overlay_service.dart` - 闪烁服务
- `lib/services/notification_service.dart` - 通知服务
- `lib/models/notification_request.dart` - 数据模型

## 效果说明

### 视觉效果
1. **淡入**: 屏幕逐渐显示指定颜色的透明蒙版（0 → 80% 透明度）
2. **保持**: 蒙版保持显示指定时间
3. **淡出**: 蒙版逐渐消失（80% → 0% 透明度）
4. **关闭**: 覆盖窗口自动关闭

### 覆盖范围
- ✅ 全屏覆盖
- ✅ 覆盖所有应用（包括全屏应用）
- ✅ 置顶显示
- ✅ 50% 透明度（可调整）

## 故障排除

### 问题 1: 窗口不显示
**原因**: 依赖未安装或平台未配置
**解决**:
```bash
flutter pub get
flutter clean && flutter run -d macos
```

### 问题 2: 窗口不全屏
**原因**: window_manager 未正确初始化
**解决**: 检查 `overlay_main.dart` 中的 `_configureOverlayWindow()` 函数

### 问题 3: 窗口不透明
**原因**: 平台原生配置缺失
**解决**: 参考 `flash-screen/window-config.md` 配置平台代码

### 问题 4: 窗口未置顶
**原因**: `setAlwaysOnTop` 未生效
**解决**: 确保在显示窗口后调用，检查平台权限

## 相关文档

- [窗口配置详解](window-config.md)
- [快速开始](quick-start.md)
- [API 参考](../plan.md#api-接口)

## 许可证

MIT
