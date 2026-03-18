import 'package:flutter/material.dart';

/// SNotice 应用色彩系统（极简工具软件风）
class AppColors {
  AppColors._();

  // ========== 品牌主色 ==========

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryContainer = Color(0xFFEFF6FF);

  // ========== 信号色系统 ==========

  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ========== 提醒类型专属色 ==========

  static const Color flashOverlay = Color(0xFFD97706);
  static const Color flashOverlayLight = Color(0xFFFEF3C7);
  static const Color notification = Color(0xFF2563EB);
  static const Color notificationLight = Color(0xFFEFF6FF);

  // ========== 中性色（浅色主题）==========

  static const Color surface = Color(0xFFECEFF3);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF6B7280);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // ========== 中性色（深色主题）==========

  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceContainerDark = Color(0xFF111827);
  static const Color surfaceContainerHighDark = Color(0xFF1F2937);
  static const Color borderDarkTheme = Color(0xFF374151);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);

  // ========== 功能色 ==========

  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);
  static const Color scrim = Color(0xFF000000);
  static const Color scrimLight = Color(0x80000000);

  // ========== 桌面壳层（双栏布局） ==========

  static const Color windowBackground = Color(0xFFECEFF3);
  static const Color sidebarBackground = Color(0xFFF7F8FA);
  static const Color workspaceBackground = Color(0xFFECEFF3);
  static const Color panelBackground = Color(0xFFFFFFFF);
  static const Color shellBorder = Color(0xFFD1D5DB);
  static const Color sidebarSelected = Color(0xFFE8EEFF);
  static const Color shellAccent = Color(0xFF2563EB);
  static const Color logInfo = Color(0xFF2563EB);
  static const Color logWarning = Color(0xFFD97706);
  static const Color logError = Color(0xFFDC2626);

  // ========== 悬浮窗口专用色 ==========

  static const Color overlayBackground = Color(0xCC000000);
  static const Color overlayBorder = Color(0x33FFFFFF);

  static Color getReminderTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'flash':
        return flashOverlay;
      case 'notification':
      default:
        return notification;
    }
  }

  static Color getReminderTypeLightColor(String type) {
    switch (type.toLowerCase()) {
      case 'flash':
        return flashOverlayLight;
      case 'notification':
      default:
        return notificationLight;
    }
  }

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
