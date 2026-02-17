import 'package:flutter/material.dart';

/// SNotice 应用字体排版系统
///
/// 字体选择：
/// - 标题：PlusJakartaSans（现代几何感）
/// - 正文：系统默认（中文优化）
/// - 数字：等宽字体（时间显示）
class AppTextStyles {
  AppTextStyles._();

  // ========== 字体族名称 ==========

  /// 标题字体
  static const String displayFont = 'PlusJakartaSans';

  /// 正文字体（使用系统默认以支持中文）
  static const String? bodyFont = null;

  // ========== 展示级标题 ==========

  /// 超大标题 - 40px，用于欢迎页面、空状态主标题
  static const TextStyle displayXl = TextStyle(
    fontFamily: displayFont,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1.0,
  );

  /// 大标题 - 32px，用于页面主标题
  static const TextStyle displayLg = TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// 中等大标题 - 28px
  static const TextStyle displayMd = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.3,
  );

  // ========== 标题级 ==========

  /// 页面标题 - 24px
  static const TextStyle headlineLg = TextStyle(
    fontFamily: displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  /// 区块标题 - 20px
  static const TextStyle headlineMd = TextStyle(
    fontFamily: displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// 小区块标题 - 18px
  static const TextStyle headlineSm = TextStyle(
    fontFamily: displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ========== 正文级 ==========

  /// 大正文 - 16px
  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 标准正文 - 14px
  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 小正文 - 13px
  static const TextStyle bodySm = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // ========== 标签/辅助文字 ==========

  /// 标签 - 12px
  static const TextStyle labelMd = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// 小标签 - 11px
  static const TextStyle labelSm = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  /// 辅助文字 - 12px（常规字重）
  static const TextStyle captionMd = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// 小辅助文字 - 11px
  static const TextStyle captionSm = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  // ========== 卡片专用 ==========

  /// 卡片标题
  static const TextStyle cardTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// 卡片副标题
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ========== 数字/时间专用 ==========

  /// 大时间显示 - 48px
  static const TextStyle timeDisplayLg = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    fontSize: 48,
    fontWeight: FontWeight.w300,
    height: 1.0,
    letterSpacing: -2,
  );

  /// 中等时间显示 - 36px
  static const TextStyle timeDisplayMd = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: -1,
  );

  /// 小时间显示 - 24px
  static const TextStyle timeDisplaySm = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.5,
  );

  /// 数字统计 - 32px
  static const TextStyle numberDisplay = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -1,
  );

  // ========== 按钮文字 ==========

  /// 大按钮文字
  static const TextStyle buttonLg = TextStyle(
    fontFamily: displayFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// 普通按钮文字
  static const TextStyle buttonMd = TextStyle(
    fontFamily: displayFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// 小按钮文字
  static const TextStyle buttonSm = TextStyle(
    fontFamily: displayFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  // ========== 代码/等宽 ==========

  /// 代码文字
  static const TextStyle code = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 小代码文字
  static const TextStyle codeSm = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ========== 辅助方法 ==========

  /// 创建带颜色的文本样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 创建带行高的文本样式
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }
}

/// 文本样式扩展
extension TextStyleExtension on TextStyle {
  /// 设置颜色
  TextStyle withColor(Color color) => copyWith(color: color);

  /// 设置字重
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);

  /// 设置大小
  TextStyle withSize(double size) => copyWith(fontSize: size);

  /// 设置行高
  TextStyle withHeight(double height) => copyWith(height: height);

  /// 设置透明度
  TextStyle withOpacity(double opacity) =>
      copyWith(color: color?.withValues(alpha: opacity));
}
