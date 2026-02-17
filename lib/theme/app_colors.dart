import 'package:flutter/material.dart';

/// SNotice 应用色彩系统
///
/// 色彩设计理念：电子信号感 - 科技感但不冰冷
class AppColors {
  AppColors._();

  // ========== 品牌主色 ==========

  /// 主色调 - Indigo，科技感且温暖
  static const Color primary = Color(0xFF6366F1);

  /// 主色浅色变体
  static const Color primaryLight = Color(0xFFA5B4FC);

  /// 主色深色变体
  static const Color primaryDark = Color(0xFF4338CA);

  /// 主色容器（用于卡片背景等）
  static const Color primaryContainer = Color(0xFFE0E7FF);

  // ========== 信号色系统 ==========

  /// 成功色 - Emerald，用于运行中、完成状态
  static const Color success = Color(0xFF10B981);

  /// 成功色浅色变体
  static const Color successLight = Color(0xFFD1FAE5);

  /// 警告色 - Amber，用于即将到期、注意事项
  static const Color warning = Color(0xFFF59E0B);

  /// 警告色浅色变体
  static const Color warningLight = Color(0xFFFEF3C7);

  /// 错误色 - Red，用于错误、紧急状态
  static const Color error = Color(0xFFEF4444);

  /// 错误色浅色变体
  static const Color errorLight = Color(0xFFFEE2E2);

  /// 信息色 - Blue，用于一般信息提示
  static const Color info = Color(0xFF3B82F6);

  /// 信息色浅色变体
  static const Color infoLight = Color(0xFFDBEAFE);

  // ========== 提醒类型专属色 ==========

  /// 闪光提醒色 - Pink
  static const Color flashOverlay = Color(0xFFEC4899);

  /// 闪光提醒色浅色变体
  static const Color flashOverlayLight = Color(0xFFFCE7F3);

  /// 通知色 - Violet
  static const Color notification = Color(0xFF8B5CF6);

  /// 通知色浅色变体
  static const Color notificationLight = Color(0xFFEDE9FE);

  // ========== 中性色（浅色主题）==========

  /// 背景白色
  static const Color surface = Color(0xFFFAFAFA);

  /// 表面色（卡片等）
  static const Color surfaceContainer = Color(0xFFF4F4F5);

  /// 表面色高亮
  static const Color surfaceContainerHigh = Color(0xFFE4E4E7);

  /// 边框色
  static const Color border = Color(0xFFE4E4E7);

  /// 边框色（深）
  static const Color borderDark = Color(0xFFD4D4D8);

  /// 主文字色
  static const Color textPrimary = Color(0xFF18181B);

  /// 次要文字色
  static const Color textSecondary = Color(0xFF52525B);

  /// 禁用/辅助文字色
  static const Color textTertiary = Color(0xFFA1A1AA);

  /// 占位符文字色
  static const Color textHint = Color(0xFFD4D4D8);

  // ========== 中性色（深色主题）==========

  /// 深色背景
  static const Color surfaceDark = Color(0xFF0A0A0C);

  /// 深色表面色
  static const Color surfaceContainerDark = Color(0xFF18181B);

  /// 深色表面色高亮
  static const Color surfaceContainerHighDark = Color(0xFF27272A);

  /// 深色主题边框色
  static const Color borderDarkTheme = Color(0xFF27272A);

  /// 深色主文字色
  static const Color textPrimaryDark = Color(0xFFFAFAFA);

  /// 深色次要文字色
  static const Color textSecondaryDark = Color(0xFFA1A1AA);

  /// 深色禁用/辅助文字色
  static const Color textTertiaryDark = Color(0xFF71717A);

  // ========== 功能色 ==========

  /// 分割线色
  static const Color divider = Color(0xFFE4E4E7);

  /// 分割线色（深色主题）
  static const Color dividerDark = Color(0xFF27272A);

  /// 遮罩色
  static const Color scrim = Color(0xFF000000);

  /// 遮罩色（浅色）
  static const Color scrimLight = Color(0x80000000);

  // ========== 悬浮窗口专用色 ==========

  /// 悬浮窗口背景
  static const Color overlayBackground = Color(0xCC000000);

  /// 悬浮窗口边框
  static const Color overlayBorder = Color(0x33FFFFFF);

  // ========== 辅助方法 ==========

  /// 根据提醒类型获取对应颜色
  static Color getReminderTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'flash':
        return flashOverlay;
      case 'notification':
      default:
        return notification;
    }
  }

  /// 根据提醒类型获取浅色变体
  static Color getReminderTypeLightColor(String type) {
    switch (type.toLowerCase()) {
      case 'flash':
        return flashOverlayLight;
      case 'notification':
      default:
        return notificationLight;
    }
  }

  /// 根据优先级获取颜色
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return error;
      case 2:
        return warning;
      case 3:
      default:
        return textSecondary;
    }
  }
}
