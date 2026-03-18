import 'package:flutter/material.dart';

/// SNotice 应用字体排版系统（极简工具软件风）
class AppTextStyles {
  AppTextStyles._();

  // macOS 优先系统字体，其他平台回退常见 UI 字体
  static const String displayFont = '.SF Pro Display';
  static const String bodyFont = '.SF Pro Text';

  static const List<String> displayFallback = [
    'Segoe UI',
    'PingFang SC',
    'Hiragino Sans GB',
    'Noto Sans CJK SC',
    'Microsoft YaHei',
    'sans-serif',
  ];

  static const List<String> bodyFallback = displayFallback;

  static const TextStyle displayXl = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.4,
  );

  static const TextStyle displayLg = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.22,
    letterSpacing: -0.15,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.28,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.32,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.48,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.15,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.2,
  );

  static const TextStyle captionMd = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle captionSm = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: displayFont,
    fontFamilyFallback: displayFallback,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle timeDisplayLg = TextStyle(
    fontFamily: 'Menlo',
    fontFamilyFallback: ['Consolas', 'monospace'],
    fontSize: 44,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -1.4,
  );

  static const TextStyle timeDisplayMd = TextStyle(
    fontFamily: 'Menlo',
    fontFamilyFallback: ['Consolas', 'monospace'],
    fontSize: 34,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.9,
  );

  static const TextStyle timeDisplaySm = TextStyle(
    fontFamily: 'Menlo',
    fontFamilyFallback: ['Consolas', 'monospace'],
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -0.5,
  );

  static const TextStyle numberDisplay = TextStyle(
    fontFamily: 'Menlo',
    fontFamilyFallback: ['Consolas', 'monospace'],
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -0.7,
  );

  static const TextStyle buttonLg = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonMd = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSm = TextStyle(
    fontFamily: bodyFont,
    fontFamilyFallback: bodyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle code = TextStyle(
    fontFamily: 'Menlo',
    fontFamilyFallback: ['Consolas', 'monospace'],
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.42,
  );

  static const TextStyle codeSm = TextStyle(
    fontFamily: 'Menlo',
    fontFamilyFallback: ['Consolas', 'monospace'],
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }
}

extension TextStyleExtension on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);

  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);

  TextStyle withSize(double size) => copyWith(fontSize: size);

  TextStyle withHeight(double height) => copyWith(height: height);
}
