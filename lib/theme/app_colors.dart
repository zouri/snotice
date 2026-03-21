import 'package:flutter/material.dart';

/// SNotice 应用色彩系统
///
/// 颜色来源于最新 pen 设计稿中的 `mode: day/night` token。
class AppColors {
  AppColors._();

  // ========== 品牌主色 ==========

  static const Color primary = Color(0xFF4F7BFF);
  static const Color primaryLight = Color(0xFF6B8CFF);
  static const Color primaryDark = Color(0xFF2D447D);
  static const Color primaryContainer = Color(0xFFDCE8FF);
  static const Color primaryContainerDark = Color(0xFF2D447D);

  // ========== 信号色系统 ==========

  static const Color success = Color(0xFF16A34A);
  static const Color successDark = Color(0xFF43C174);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFF87171);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = primary;
  static const Color infoLight = Color(0xFFDBEAFE);

  // ========== 提醒类型专属色 ==========

  static const Color flashOverlay = warning;
  static const Color flashOverlayLight = warningLight;
  static const Color notification = primary;
  static const Color notificationLight = primaryContainer;

  // ========== 浅色主题 ==========

  static const Color surface = Color(0xFFECEFF3);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFF3F4F6);
  static const Color border = Color(0xFFD1D5DB);
  static const Color borderSoft = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF9CA3AF);

  // ========== 深色主题 ==========

  static const Color surfaceDark = Color(0xFF0B1020);
  static const Color surfaceContainerDark = Color(0xFF1A2236);
  static const Color surfaceContainerHighDark = Color(0xFF131A2C);
  static const Color borderDarkTheme = Color(0xFF2A344B);
  static const Color borderSoftDark = Color(0xFF34415E);
  static const Color textPrimaryDark = Color(0xFFF3F6FF);
  static const Color textSecondaryDark = Color(0xFFB9C2D8);
  static const Color textTertiaryDark = Color(0xFF8F9AB5);
  static const Color textHintDark = Color(0xFF8F9AB5);

  // ========== 功能色 ==========

  static const Color divider = borderSoft;
  static const Color dividerDark = borderSoftDark;
  static const Color scrim = Color(0xFF000000);
  static const Color scrimLight = Color(0x80000000);

  // ========== 桌面壳层 ==========

  static const Color windowBackground = surface;
  static const Color windowBackgroundDark = surfaceDark;
  static const Color sidebarBackground = Color(0xFFF7F8FA);
  static const Color sidebarBackgroundDark = surfaceContainerHighDark;
  static const Color workspaceBackground = surface;
  static const Color workspaceBackgroundDark = surfaceDark;
  static const Color panelBackground = surfaceContainer;
  static const Color panelBackgroundDark = surfaceContainerHighDark;
  static const Color shellBorder = border;
  static const Color shellBorderDark = borderDarkTheme;
  static const Color sidebarSelected = primaryContainer;
  static const Color sidebarSelectedDark = primaryContainerDark;
  static const Color shellAccent = primary;
  static const Color logInfo = primary;
  static const Color logWarning = warning;
  static const Color logError = error;

  // ========== 悬浮窗口专用色 ==========

  static const Color overlayBackground = Color(0xCCFFFFFF);
  static const Color overlayBackgroundDark = Color(0xCC111827);
  static const Color overlayBorder = Color(0x33FFFFFF);

  static bool isDark(Brightness brightness) => brightness == Brightness.dark;

  static Color surfaceFor(Brightness brightness) {
    return isDark(brightness) ? surfaceDark : surface;
  }

  static Color surfaceContainerFor(Brightness brightness) {
    return isDark(brightness) ? surfaceContainerDark : surfaceContainer;
  }

  static Color surfaceContainerHighFor(Brightness brightness) {
    return isDark(brightness)
        ? surfaceContainerHighDark
        : surfaceContainerHigh;
  }

  static Color borderFor(Brightness brightness) {
    return isDark(brightness) ? borderDarkTheme : border;
  }

  static Color borderSoftFor(Brightness brightness) {
    return isDark(brightness) ? borderSoftDark : borderSoft;
  }

  static Color textHintFor(Brightness brightness) {
    return isDark(brightness) ? textHintDark : textHint;
  }

  static Color windowBackgroundFor(Brightness brightness) {
    return isDark(brightness) ? windowBackgroundDark : windowBackground;
  }

  static Color sidebarBackgroundFor(Brightness brightness) {
    return isDark(brightness) ? sidebarBackgroundDark : sidebarBackground;
  }

  static Color workspaceBackgroundFor(Brightness brightness) {
    return isDark(brightness) ? workspaceBackgroundDark : workspaceBackground;
  }

  static Color panelBackgroundFor(Brightness brightness) {
    return isDark(brightness) ? panelBackgroundDark : panelBackground;
  }

  static Color shellBorderFor(Brightness brightness) {
    return isDark(brightness) ? shellBorderDark : shellBorder;
  }

  static Color sidebarSelectedFor(Brightness brightness) {
    return isDark(brightness) ? sidebarSelectedDark : sidebarSelected;
  }

  static Color overlayBackgroundFor(Brightness brightness) {
    return isDark(brightness) ? overlayBackgroundDark : overlayBackground;
  }

  static Color successFor(Brightness brightness) {
    return isDark(brightness) ? successDark : success;
  }

  static Color errorFor(Brightness brightness) {
    return isDark(brightness) ? errorDark : error;
  }

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
