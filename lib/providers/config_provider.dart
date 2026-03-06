import 'package:flutter/foundation.dart';
import '../models/app_config.dart';

class ConfigProvider with ChangeNotifier {
  AppConfig _config = AppConfig();

  AppConfig get config => _config;

  void updateConfig(AppConfig config) {
    _config = config;
    notifyListeners();
  }
}
