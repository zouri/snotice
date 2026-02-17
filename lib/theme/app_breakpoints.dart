import 'package:flutter/material.dart';

/// SNotice 应用响应式断点系统
///
/// 定义不同设备类型的断点
class AppBreakpoints {
  AppBreakpoints._();

  // ========== 断点值 ==========

  /// 手机 - 小于 600px
  static const double mobile = 600;

  /// 平板 - 600px 到 900px
  static const double tablet = 900;

  /// 桌面 - 900px 到 1200px
  static const double desktop = 1200;

  /// 宽屏 - 大于 1200px
  static const double wide = 1200;

  /// 超宽屏 - 大于 1600px
  static const double ultraWide = 1600;

  // ========== 侧边栏宽度 ==========

  /// 紧凑侧边栏宽度
  static const double sidebarCompact = 200;

  /// 标准侧边栏宽度
  static const double sidebarStandard = 260;

  /// 宽侧边栏宽度
  static const double sidebarWide = 300;

  // ========== 辅助方法 ==========

  /// 判断是否为手机屏幕
  static bool isMobile(double width) => width < mobile;

  /// 判断是否为平板屏幕
  static bool isTablet(double width) => width >= mobile && width < desktop;

  /// 判断是否为桌面屏幕
  static bool isDesktop(double width) => width >= desktop && width < wide;

  /// 判断是否为宽屏
  static bool isWide(double width) => width >= wide;

  /// 判断是否为超宽屏
  static bool isUltraWide(double width) => width >= ultraWide;

  /// 获取当前设备类型
  static DeviceType getDeviceType(double width) {
    if (width < mobile) return DeviceType.mobile;
    if (width < desktop) return DeviceType.tablet;
    if (width < wide) return DeviceType.desktop;
    return DeviceType.wide;
  }

  /// 获取推荐的侧边栏宽度
  static double getSidebarWidth(double width) {
    if (width < tablet) return 0; // 手机端不显示侧边栏
    if (width < desktop) return sidebarCompact;
    if (width < wide) return sidebarStandard;
    return sidebarWide;
  }

  /// 获取推荐的面板宽度（右侧详情面板）
  static double getPanelWidth(double width) {
    if (width < desktop) return 0;
    if (width < wide) return 280;
    return 320;
  }

  /// 获取内容区域最大宽度
  static double getContentMaxWidth(double width) {
    if (width < mobile) return width;
    if (width < tablet) return mobile - 32;
    if (width < desktop) return tablet - 64;
    if (width < wide) return desktop - 64;
    return wide;
  }

  /// 获取列数（用于网格布局）
  static int getColumnCount(double width) {
    if (width < mobile) return 1;
    if (width < tablet) return 2;
    if (width < desktop) return 2;
    if (width < wide) return 3;
    return 4;
  }
}

/// 设备类型枚举
enum DeviceType {
  mobile,
  tablet,
  desktop,
  wide,
}

/// 设备类型扩展
extension DeviceTypeExtension on DeviceType {
  /// 是否为手机
  bool get isMobile => this == DeviceType.mobile;

  /// 是否为平板
  bool get isTablet => this == DeviceType.tablet;

  /// 是否为桌面
  bool get isDesktop => this == DeviceType.desktop;

  /// 是否为宽屏
  bool get isWide => this == DeviceType.wide;

  /// 是否为触摸设备（手机或平板）
  bool get isTouch => isMobile || isTablet;

  /// 获取显示名称
  String get displayName {
    switch (this) {
      case DeviceType.mobile:
        return '手机';
      case DeviceType.tablet:
        return '平板';
      case DeviceType.desktop:
        return '桌面';
      case DeviceType.wide:
        return '宽屏';
    }
  }
}

/// 响应式构建器组件
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
    this.wide,
  });

  /// 通用构建器（优先使用）
  final Widget Function(BuildContext context, DeviceType deviceType)? builder;

  /// 手机布局
  final Widget? mobile;

  /// 平板布局
  final Widget? tablet;

  /// 桌面布局
  final Widget? desktop;

  /// 宽屏布局
  final Widget? wide;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = AppBreakpoints.getDeviceType(width);

    // 如果提供了通用构建器，使用它
    if (builder != null) {
      return builder!(context, deviceType);
    }

    // 否则根据设备类型返回对应布局
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? tablet ?? desktop ?? wide ?? const SizedBox.shrink();
      case DeviceType.tablet:
        return tablet ?? desktop ?? wide ?? mobile ?? const SizedBox.shrink();
      case DeviceType.desktop:
        return desktop ?? wide ?? tablet ?? mobile ?? const SizedBox.shrink();
      case DeviceType.wide:
        return wide ?? desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
    }
  }
}

/// 响应式值
class ResponsiveValue<T> {
  const ResponsiveValue({
    this.mobile,
    this.tablet,
    this.desktop,
    this.wide,
    required this.defaultValue,
  });

  final T? mobile;
  final T? tablet;
  final T? desktop;
  final T? wide;
  final T defaultValue;

  /// 根据宽度获取值
  T value(double width) {
    final deviceType = AppBreakpoints.getDeviceType(width);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? tablet ?? desktop ?? wide ?? defaultValue;
      case DeviceType.tablet:
        return tablet ?? desktop ?? wide ?? mobile ?? defaultValue;
      case DeviceType.desktop:
        return desktop ?? wide ?? tablet ?? mobile ?? defaultValue;
      case DeviceType.wide:
        return wide ?? desktop ?? tablet ?? mobile ?? defaultValue;
    }
  }

  /// 从 BuildContext 获取值
  T of(BuildContext context) {
    return value(MediaQuery.of(context).size.width);
  }
}

/// 响应式间距
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile = const EdgeInsets.all(16),
    this.tablet = const EdgeInsets.all(24),
    this.desktop = const EdgeInsets.all(32),
    this.wide = const EdgeInsets.all(40),
  });

  final Widget child;
  final EdgeInsets mobile;
  final EdgeInsets tablet;
  final EdgeInsets desktop;
  final EdgeInsets wide;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = AppBreakpoints.getDeviceType(width);

    EdgeInsets padding;
    switch (deviceType) {
      case DeviceType.mobile:
        padding = mobile;
        break;
      case DeviceType.tablet:
        padding = tablet;
        break;
      case DeviceType.desktop:
        padding = desktop;
        break;
      case DeviceType.wide:
        padding = wide;
        break;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}
