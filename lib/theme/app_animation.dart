import 'package:flutter/animation.dart';

/// SNotice 应用动画系统
///
/// 提供一致的动画时长和曲线
class AppAnimation {
  AppAnimation._();

  // ========== 动画时长 ==========

  /// 即时 - 100ms，用于微小的状态变化
  static const Duration instant = Duration(milliseconds: 100);

  /// 快速 - 150ms，用于小型组件状态变化
  static const Duration fast = Duration(milliseconds: 150);

  /// 普通 - 250ms，用于大多数过渡动画
  static const Duration normal = Duration(milliseconds: 250);

  /// 中等 - 350ms，用于较复杂的过渡
  static const Duration medium = Duration(milliseconds: 350);

  /// 慢速 - 500ms，用于大型组件或页面过渡
  static const Duration slow = Duration(milliseconds: 500);

  /// 很慢 - 800ms，用于特殊的戏剧性效果
  static const Duration verySlow = Duration(milliseconds: 800);

  // ========== 动画曲线 ==========

  /// 标准缓出 - 从快到慢
  static const Curve easeOut = Curves.easeOutCubic;

  /// 标准缓入缓出 - 慢到快到慢
  static const Curve easeInOut = Curves.easeInOutCubic;

  /// 弹性效果 - 轻微回弹
  static const Curve bounce = Curves.elasticOut;

  /// 弹性效果（轻微）- 更柔和的回弹
  static const Curve bounceSoft = Curves.easeOutBack;

  /// 线性
  static const Curve linear = Curves.linear;

  /// 强调缓出 - 更明显的减速
  static const Curve emphasized = Curves.easeOutExpo;

  /// 减速 - 快速减速
  static const Curve decelerate = Curves.decelerate;

  // ========== 预设动画时长 - 组件级别 ==========

  /// 按钮点击反馈
  static const Duration buttonPress = instant;

  /// 开关切换
  static const Duration switchToggle = normal;

  /// 展开/收起
  static const Duration expand = normal;

  /// 页面切换
  static const Duration pageTransition = medium;

  /// 弹窗出现
  static const Duration dialogShow = normal;

  /// 弹窗消失
  static const Duration dialogDismiss = fast;

  /// 列表项入场
  static const Duration listItemEnter = normal;

  /// Toast 显示
  static const Duration toastShow = normal;

  /// 脉冲效果
  static const Duration pulse = Duration(milliseconds: 1200);
}

/// 列表动画辅助
class ListAnimation {
  ListAnimation._();

  /// 计算交错动画间隔
  ///
  /// [index] 列表项索引
  /// [total] 总项数
  /// [totalDuration] 总动画时长
  static Interval staggerInterval({
    required int index,
    int? total,
    Duration totalDuration = AppAnimation.slow,
  }) {
    final totalMs = totalDuration.inMilliseconds;
    final itemDuration = totalMs * 0.6; // 每项动画时长
    final staggerDelay = (totalMs - itemDuration) / (total ?? 10).clamp(1, 20);

    final start = (index * staggerDelay) / totalMs;
    final end = (start * totalMs + itemDuration) / totalMs;

    return Interval(
      start.clamp(0.0, 1.0),
      end.clamp(0.0, 1.0),
      curve: AppAnimation.easeOut,
    );
  }

  /// 简单的交错延迟
  ///
  /// [index] 列表项索引
  /// [baseDelay] 基础延迟（毫秒）
  static Duration staggerDelay(int index, {int baseDelay = 50}) {
    return Duration(milliseconds: index * baseDelay);
  }
}

/// 动画状态扩展
extension AnimationExtension on AnimationController {
  /// 创建淡入动画
  Animation<double> get fadeIn => CurvedAnimation(
        parent: this,
        curve: AppAnimation.easeOut,
      );

  /// 创建滑入动画（从下方）
  Animation<Offset> get slideInFromBottom => Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: this,
        curve: AppAnimation.easeOut,
      ));

  /// 创建滑入动画（从右侧）
  Animation<Offset> get slideInFromRight => Tween<Offset>(
        begin: const Offset(0.1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: this,
        curve: AppAnimation.easeOut,
      ));

  /// 创建缩放动画
  Animation<double> get scaleIn => Tween<double>(
        begin: 0.95,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: this,
        curve: AppAnimation.easeOut,
      ));
}
