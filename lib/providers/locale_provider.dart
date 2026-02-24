import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 语言偏好提供者
///
/// 管理应用的语言设置，支持跟随系统或手动切换语言。
/// 语言偏好会持久化存储。
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';

  Locale? _locale;
  bool _isLoaded = false;

  /// 当前语言，null 表示跟随系统
  Locale? get locale => _locale;

  /// 是否已加载
  bool get isLoaded => _isLoaded;

  /// 从持久化存储加载语言设置
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);

    if (localeCode != null && localeCode.isNotEmpty) {
      final parts = localeCode.split('_');
      if (parts.length >= 2) {
        _locale = Locale(parts[0], parts[1]);
      } else {
        _locale = Locale(parts[0]);
      }
    } else {
      _locale = null; // 跟随系统
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// 设置语言
  ///
  /// 传入 null 表示跟随系统
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      final localeCode = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await prefs.setString(_localeKey, localeCode);
    }

    notifyListeners();
  }

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];

  /// 语言选项
  static const List<LocaleOption> localeOptions = [
    LocaleOption(null, '跟随系统', 'System'),
    LocaleOption(Locale('en', 'US'), 'English', 'English'),
    LocaleOption(Locale('zh', 'CN'), '中文', '中文'),
  ];
}

/// 语言选项
class LocaleOption {
  final Locale? locale;
  final String labelEn;
  final String labelZh;

  const LocaleOption(this.locale, this.labelEn, this.labelZh);

  /// 根据当前语言获取显示标签
  String getLabel(Locale? currentLocale) {
    if (currentLocale?.languageCode == 'zh') {
      return labelZh;
    }
    return labelEn;
  }
}
