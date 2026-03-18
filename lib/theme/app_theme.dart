import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// SNotice 应用主题配置
class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    textTheme: _lightTextTheme,
    isDark: false,
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    textTheme: _darkTextTheme,
    isDark: true,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isDark,
  }) {
    final borderColor = colorScheme.outlineVariant;
    final cardColor = isDark
        ? AppColors.surfaceContainerDark
        : AppColors.surfaceContainer;
    final inputFill = isDark
        ? AppColors.surfaceContainerHighDark
        : AppColors.surfaceContainer;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineMd.copyWith(
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint),
        labelStyle: AppTextStyles.bodyMd.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.buttonMd,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.buttonMd,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: borderColor, width: 1),
          textStyle: AppTextStyles.buttonMd,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          textStyle: AppTextStyles.buttonMd,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: AppSpacing.md,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: inputFill,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: AppColors.surfaceContainerHigh,
        labelStyle: AppTextStyles.labelMd.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: AppTextStyles.labelMd,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: borderColor, width: 1),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMd.copyWith(color: colorScheme.primary);
          }
          return AppTextStyles.labelMd.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor, width: 1),
        ),
        titleTextStyle: AppTextStyles.headlineMd.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMd.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: AppTextStyles.bodyMd.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceContainerHighDark
              : AppColors.textPrimary,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: AppTextStyles.captionMd.copyWith(
          color: isDark ? AppColors.textPrimaryDark : Colors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primaryContainer,
        selectionHandleColor: colorScheme.primary,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        radius: const Radius.circular(6),
        thickness: WidgetStateProperty.all(6),
      ),
      listTileTheme: ListTileThemeData(
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return isDark
              ? AppColors.surfaceContainerHighDark
              : AppColors.surfaceContainerHigh;
        }),
      ),
    );
  }

  static TextTheme get _lightTextTheme => _buildTextTheme(
    primary: AppColors.textPrimary,
    secondary: AppColors.textSecondary,
    tertiary: AppColors.textTertiary,
  );

  static TextTheme get _darkTextTheme => _buildTextTheme(
    primary: AppColors.textPrimaryDark,
    secondary: AppColors.textSecondaryDark,
    tertiary: AppColors.textTertiaryDark,
  );

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLg.copyWith(color: primary),
      displayMedium: AppTextStyles.displayMd.copyWith(color: primary),
      displaySmall: AppTextStyles.headlineLg.copyWith(color: primary),
      headlineLarge: AppTextStyles.headlineLg.copyWith(color: primary),
      headlineMedium: AppTextStyles.headlineMd.copyWith(color: primary),
      headlineSmall: AppTextStyles.headlineSm.copyWith(color: primary),
      titleLarge: AppTextStyles.headlineMd.copyWith(color: primary),
      titleMedium: AppTextStyles.bodyLg.copyWith(color: primary),
      titleSmall: AppTextStyles.bodyMd.copyWith(color: primary),
      bodyLarge: AppTextStyles.bodyLg.copyWith(color: primary),
      bodyMedium: AppTextStyles.bodyMd.copyWith(color: primary),
      bodySmall: AppTextStyles.bodySm.copyWith(color: secondary),
      labelLarge: AppTextStyles.buttonMd.copyWith(color: primary),
      labelMedium: AppTextStyles.labelMd.copyWith(color: secondary),
      labelSmall: AppTextStyles.labelSm.copyWith(color: tertiary),
    );
  }

  static ColorScheme get _lightColorScheme {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return base.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.notification,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.notificationLight,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.successLight,
      onTertiaryContainer: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      scrim: AppColors.scrim,
      inversePrimary: AppColors.primaryLight,
      surfaceTint: Colors.transparent,
    );
  }

  static ColorScheme get _darkColorScheme {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      primary: AppColors.primaryLight,
      onPrimary: const Color(0xFF172554),
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.textPrimaryDark,
      secondary: const Color(0xFF93C5FD),
      onSecondary: const Color(0xFF082F49),
      secondaryContainer: const Color(0xFF1E3A8A),
      onSecondaryContainer: AppColors.textPrimaryDark,
      tertiary: const Color(0xFF6EE7B7),
      onTertiary: const Color(0xFF064E3B),
      tertiaryContainer: const Color(0xFF065F46),
      onTertiaryContainer: Colors.white,
      error: const Color(0xFFF87171),
      onError: const Color(0xFF7F1D1D),
      errorContainer: const Color(0xFF7F1D1D),
      onErrorContainer: const Color(0xFFFEE2E2),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.borderDarkTheme,
      outlineVariant: AppColors.dividerDark,
      scrim: AppColors.scrim,
      inversePrimary: AppColors.primary,
      surfaceTint: Colors.transparent,
    );
  }
}
