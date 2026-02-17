import 'package:flutter/material.dart';

/// SNotice 应用间距系统
///
/// 基于 4px 网格系统，提供一致的间距 token
class AppSpacing {
  AppSpacing._();

  // ========== 基础单位 ==========

  /// 基础单位 = 4px
  static const double unit = 4.0;

  // ========== 间距层级 ==========

  /// 4px - 极紧凑间距，用于紧密相关元素
  static const double xxs = 4.0;

  /// 8px - 紧凑间距，用于组件内部间距
  static const double xs = 8.0;

  /// 12px - 小间距，用于列表项间距
  static const double sm = 12.0;

  /// 16px - 中等间距，用于卡片内边距
  static const double md = 16.0;

  /// 20px - 中大间距
  static const double mdl = 20.0;

  /// 24px - 大间距，用于区块间距
  static const double lg = 24.0;

  /// 32px - 较大间距，用于章节间距
  static const double xl = 32.0;

  /// 48px - 特大间距，用于页面边距
  static const double xxl = 48.0;

  /// 64px - 巨大间距，用于主要区域分隔
  static const double xxxl = 64.0;

  // ========== 圆角 ==========

  /// 4px - 小圆角，用于小按钮、标签
  static const double radiusXs = 4.0;

  /// 6px - 较小圆角
  static const double radiusSm = 6.0;

  /// 8px - 中小圆角
  static const double radiusMdSm = 8.0;

  /// 12px - 中等圆角，用于卡片
  static const double radiusMd = 12.0;

  /// 16px - 较大圆角，用于对话框、底部抽屉
  static const double radiusLg = 16.0;

  /// 24px - 大圆角，用于模态框
  static const double radiusXl = 24.0;

  /// 完全圆角（胶囊形）
  static const double radiusFull = 9999.0;

  // ========== 边框宽度 ==========

  /// 细边框
  static const double borderThin = 1.0;

  /// 普通边框
  static const double borderMedium = 1.5;

  /// 粗边框
  static const double borderThick = 2.0;

  // ========== 图标尺寸 ==========

  /// 小图标 - 16px
  static const double iconXs = 16.0;

  /// 中小图标 - 20px
  static const double iconSm = 20.0;

  /// 中等图标 - 24px
  static const double iconMd = 24.0;

  /// 较大图标 - 32px
  static const double iconLg = 32.0;

  /// 大图标 - 48px
  static const double iconXl = 48.0;

  /// 特大图标 - 64px（空状态使用）
  static const double iconXxl = 64.0;

  // ========== 按钮尺寸 ==========

  /// 小按钮高度
  static const double buttonHeightSm = 32.0;

  /// 普通按钮高度
  static const double buttonHeightMd = 40.0;

  /// 大按钮高度
  static const double buttonHeightLg = 48.0;

  // ========== 输入框尺寸 ==========

  /// 输入框高度
  static const double inputHeight = 48.0;

  /// 小输入框高度
  static const double inputHeightSm = 40.0;

  // ========== 列表项尺寸 ==========

  /// 紧凑列表项高度
  static const double listItemHeightSm = 48.0;

  /// 普通列表项高度
  static const double listItemHeightMd = 56.0;

  /// 大列表项高度
  static const double listItemHeightLg = 72.0;

  // ========== 侧边栏宽度 ==========

  /// 紧凑侧边栏宽度
  static const double sidebarWidthCompact = 220.0;

  /// 普通侧边栏宽度
  static const double sidebarWidthMd = 260.0;

  /// 宽侧边栏宽度
  static const double sidebarWidthLg = 300.0;
}

/// 阴影系统
class AppShadows {
  AppShadows._();

  /// 无阴影
  static List<BoxShadow> get none => [];

  /// 小阴影 - 轻微抬升
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// 中等阴影 - 卡片使用
  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// 大阴影 - 弹出层使用
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// 特大阴影 - 模态框使用
  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 32,
          offset: const Offset(0, 16),
        ),
      ];

  /// 内阴影效果
  static List<BoxShadow> get inner => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];

  /// 彩色阴影（用于强调）
  static List<BoxShadow> colored(Color color, {double opacity = 0.3}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

/// 边距扩展方法
extension SpacingExtension on num {
  /// 转换为 EdgeInsets.all
  EdgeInsets get paddingAll => EdgeInsets.all(toDouble());

  /// 转换为 EdgeInsets.symmetric(horizontal)
  EdgeInsets get paddingHorizontal => EdgeInsets.symmetric(horizontal: toDouble());

  /// 转换为 EdgeInsets.symmetric(vertical)
  EdgeInsets get paddingVertical => EdgeInsets.symmetric(vertical: toDouble());

  /// 转换为 SizedBox
  SizedBox get box => SizedBox(width: toDouble(), height: toDouble());

  /// 水平间距
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  /// 垂直间距
  SizedBox get verticalSpace => SizedBox(height: toDouble());
}
