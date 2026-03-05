import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// SNotice 应用主题配置
///
/// 支持明暗两种主题模式，基于 Material Design 3
class AppTheme {
  AppTheme._();

  // ========== 浅色主题 ==========

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    colorScheme: _lightColorScheme,
    textTheme: _lightTextTheme,
    primaryTextTheme: _lightTextTheme,
    scaffoldBackgroundColor: AppColors.surface,
    // AppBar 主题
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineMd.copyWith(
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    // 卡片主题
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint),
      labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
    ),
    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        ),
        textStyle: AppTextStyles.buttonMd,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        ),
        side: const BorderSide(color: AppColors.border, width: 1),
        textStyle: AppTextStyles.buttonMd,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        textStyle: AppTextStyles.buttonMd,
      ),
    ),
    // 图标按钮主题
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary),
    ),
    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: AppSpacing.lg,
    ),
    // Chip 主题
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceContainer,
      selectedColor: AppColors.primaryContainer,
      disabledColor: AppColors.surfaceContainerHigh,
      labelStyle: AppTextStyles.labelMd,
      secondaryLabelStyle: AppTextStyles.labelMd,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      side: BorderSide.none,
    ),
    // 浮动操作按钮主题
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    ),
    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainer,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    // NavigationBar 主题 (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainer,
      indicatorColor: AppColors.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.labelMd.copyWith(color: AppColors.primary);
        }
        return AppTextStyles.labelMd.copyWith(color: AppColors.textTertiary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }
        return const IconThemeData(color: AppColors.textTertiary);
      }),
    ),
    // 对话框主题
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      titleTextStyle: AppTextStyles.headlineMd,
      contentTextStyle: AppTextStyles.bodyMd,
    ),
    // 底部抽屉主题
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    // SnackBar 主题
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.bodyMd.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    // Tooltip 主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      textStyle: AppTextStyles.captionMd.copyWith(color: Colors.white),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    ),
    // 文字选择主题
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primaryContainer,
      selectionHandleColor: AppColors.primary,
    ),
    // 滚动条主题
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(
        AppColors.textTertiary.withValues(alpha: 0.3),
      ),
      trackColor: WidgetStateProperty.all(Colors.transparent),
      radius: const Radius.circular(AppSpacing.radiusFull),
      thickness: WidgetStateProperty.all(6),
    ),
    // 列表瓦片主题
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),
    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.surfaceContainerHigh;
      }),
    ),
  );

  // ========== 深色主题 ==========

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    colorScheme: _darkColorScheme,
    textTheme: _darkTextTheme,
    primaryTextTheme: _darkTextTheme,
    scaffoldBackgroundColor: AppColors.surfaceDark,
    // AppBar 主题
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineMd.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
    ),
    // 卡片主题
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerDark,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      hintStyle: AppTextStyles.bodyMd.copyWith(
        color: AppColors.textTertiaryDark,
      ),
      labelStyle: AppTextStyles.bodyMd.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),
    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        ),
        textStyle: AppTextStyles.buttonMd,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimaryDark,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMdSm),
        ),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
        textStyle: AppTextStyles.buttonMd,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        textStyle: AppTextStyles.buttonMd,
      ),
    ),
    // 图标按钮主题
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.textSecondaryDark),
    ),
    // 分割线主题
    dividerTheme: DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: AppSpacing.lg,
    ),
    // Chip 主题
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceContainerHighDark,
      selectedColor: AppColors.primaryDark,
      disabledColor: AppColors.surfaceContainerDark,
      labelStyle: AppTextStyles.labelMd.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      secondaryLabelStyle: AppTextStyles.labelMd,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      side: BorderSide.none,
    ),
    // 浮动操作按钮主题
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    ),
    // 底部导航栏主题
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerDark,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textTertiaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    // NavigationBar 主题 (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerDark,
      indicatorColor: AppColors.primaryDark,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.labelMd.copyWith(color: AppColors.primaryLight);
        }
        return AppTextStyles.labelMd.copyWith(
          color: AppColors.textTertiaryDark,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryLight);
        }
        return const IconThemeData(color: AppColors.textTertiaryDark);
      }),
    ),
    // 对话框主题
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceContainerDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      titleTextStyle: AppTextStyles.headlineMd.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      contentTextStyle: AppTextStyles.bodyMd.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),
    // 底部抽屉主题
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceContainerDark,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    // SnackBar 主题
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceContainerHighDark,
      contentTextStyle: AppTextStyles.bodyMd.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    // Tooltip 主题
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighDark,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      textStyle: AppTextStyles.captionMd.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    ),
    // 文字选择主题
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryLight,
      selectionColor: AppColors.primaryDark,
      selectionHandleColor: AppColors.primaryLight,
    ),
    // 滚动条主题
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.2)),
      trackColor: WidgetStateProperty.all(Colors.transparent),
      radius: const Radius.circular(AppSpacing.radiusFull),
      thickness: WidgetStateProperty.all(6),
    ),
    // 列表瓦片主题
    listTileTheme: ListTileThemeData(
      textColor: AppColors.textPrimaryDark,
      iconColor: AppColors.textSecondaryDark,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),
    // 开关主题
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.textTertiaryDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryDark;
        }
        return AppColors.surfaceContainerHighDark;
      }),
    ),
  );

  // ========== 颜色方案 ==========

  static TextTheme get _lightTextTheme =>
      ThemeData(brightness: Brightness.light).textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );

  static TextTheme get _darkTextTheme =>
      ThemeData(brightness: Brightness.dark).textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      );

  static ColorScheme get _lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: Color(0xFF0F172A),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE2E8F0),
    onSecondaryContainer: AppColors.textPrimary,
    tertiary: AppColors.info,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.infoLight,
    onTertiaryContainer: AppColors.textPrimary,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: Color(0xFF7F1D1D),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    shadow: Colors.black,
    scrim: AppColors.scrim,
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.primaryLight,
    surfaceTint: AppColors.primary,
  );

  static ColorScheme get _darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: Color(0xFF082F49),
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.textPrimaryDark,
    secondary: Color(0xFF94A3B8),
    onSecondary: Color(0xFF0F172A),
    secondaryContainer: Color(0xFF1E293B),
    onSecondaryContainer: AppColors.textPrimaryDark,
    tertiary: Color(0xFF93C5FD),
    onTertiary: Color(0xFF172554),
    tertiaryContainer: Color(0xFF1E3A8A),
    onTertiaryContainer: Colors.white,
    error: Color(0xFFF87171),
    onError: Color(0xFF7F1D1D),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.borderDarkTheme,
    outlineVariant: AppColors.dividerDark,
    shadow: Colors.black,
    scrim: AppColors.scrim,
    inverseSurface: Color(0xFFE2E8F0),
    onInverseSurface: Color(0xFF0F172A),
    inversePrimary: AppColors.primary,
    surfaceTint: AppColors.primaryLight,
  );
}
