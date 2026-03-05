import 'package:flutter/material.dart';

/// SNotice 应用色彩系统
///
/// 色彩设计理念：电子信号感 - 科技感但不冰冷
class AppColors {
  AppColors._();

  // ========== 品牌主色 ==========

  /// 主色调 - 深海蓝，强调可读性与稳定感
  static const Color primary = Color(0xFF0369A1);

  /// 主色浅色变体
  static const Color primaryLight = Color(0xFF38BDF8);

  /// 主色深色变体
  static const Color primaryDark = Color(0xFF0C4A6E);

  /// 主色容器（用于卡片背景等）
  static const Color primaryContainer = Color(0xFFE0F2FE);

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
  static const Color surface = Color(0xFFF8FAFC);

  /// 表面色（卡片等）
  static const Color surfaceContainer = Color(0xFFFFFFFF);

  /// 表面色高亮
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);

  /// 边框色
  static const Color border = Color(0xFFCBD5E1);

  /// 边框色（深）
  static const Color borderDark = Color(0xFF94A3B8);

  /// 主文字色
  static const Color textPrimary = Color(0xFF0F172A);

  /// 次要文字色
  static const Color textSecondary = Color(0xFF334155);

  /// 禁用/辅助文字色
  static const Color textTertiary = Color(0xFF475569);

  /// 占位符文字色
  static const Color textHint = Color(0xFF64748B);

  // ========== 中性色（深色主题）==========

  /// 深色背景
  static const Color surfaceDark = Color(0xFF020617);

  /// 深色表面色
  static const Color surfaceContainerDark = Color(0xFF0F172A);

  /// 深色表面色高亮
  static const Color surfaceContainerHighDark = Color(0xFF1E293B);

  /// 深色主题边框色
  static const Color borderDarkTheme = Color(0xFF334155);

  /// 深色主文字色
  static const Color textPrimaryDark = Color(0xFFF8FAFC);

  /// 深色次要文字色
  static const Color textSecondaryDark = Color(0xFFCBD5E1);

  /// 深色禁用/辅助文字色
  static const Color textTertiaryDark = Color(0xFF94A3B8);

  // ========== 功能色 ==========

  /// 分割线色
  static const Color divider = Color(0xFFE2E8F0);

  /// 分割线色（深色主题）
  static const Color dividerDark = Color(0xFF334155);

  /// 遮罩色
  static const Color scrim = Color(0xFF000000);

  /// 遮罩色（浅色）
  static const Color scrimLight = Color(0x80000000);

  // ========== 桌面壳层（双栏布局） ==========

  /// 窗口整体背景（参照设计图）
  static const Color windowBackground = Color(0xFFEDEDED);

  /// 左侧导航栏背景
  static const Color sidebarBackground = Color(0xFFEFF1F4);

  /// 右侧工作区背景
  static const Color workspaceBackground = Color(0xFFF5F5F5);

  /// 面板与日志项背景
  static const Color panelBackground = Color(0xFFFAFAFA);

  /// 壳层边框与分割线
  static const Color shellBorder = Color(0xFFDADDE2);

  /// 左侧导航选中态背景
  static const Color sidebarSelected = Color(0xFFBCCADF);

  /// 桌面壳层主强调色
  static const Color shellAccent = Color(0xFF2F7CF6);

  /// 调用日志 INFO 颜色
  static const Color logInfo = Color(0xFF2F7CF6);

  /// 调用日志 WARNING 颜色
  static const Color logWarning = Color(0xFFF59E0B);

  /// 调用日志 ERROR 颜色
  static const Color logError = Color(0xFFEF4444);

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
