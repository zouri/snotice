import 'package:flutter/material.dart';

/// 主题 Provider
///
/// 管理应用的主题模式（跟随系统、浅色、深色）
class ThemeProvider with ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  /// 是否为深色模式（考虑系统设置）
  bool get isDarkMode => _mode == ThemeMode.dark;

  /// 设置主题模式
  void setMode(ThemeMode mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }

  /// 切换明暗主题
  void toggle() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// 设置为浅色主题
  void setLight() {
    setMode(ThemeMode.light);
  }

  /// 设置为深色主题
  void setDark() {
    setMode(ThemeMode.dark);
  }

  /// 设置为跟随系统
  void setSystem() {
    setMode(ThemeMode.system);
  }

  /// 获取当前主题模式名称
  String get modeName {
    switch (_mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
    }
  }

  /// 根据索引设置主题模式
  void setByIndex(int index) {
    switch (index) {
      case 0:
        setSystem();
        break;
      case 1:
        setLight();
        break;
      case 2:
        setDark();
        break;
    }
  }

  /// 获取当前主题模式索引
  int get modeIndex {
    switch (_mode) {
      case ThemeMode.system:
        return 0;
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
    }
  }
}
