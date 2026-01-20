import 'package:flutter/foundation.dart';
import '../models/app_config.dart';

class ConfigProvider with ChangeNotifier {
  AppConfig _config = AppConfig();

  AppConfig get config => _config;

  void updateConfig(AppConfig config) {
    _config = config;
    notifyListeners();
  }

  void updatePort(int port) {
    _config.port = port;
    notifyListeners();
  }

  void updateAllowedIPs(List<String> ips) {
    _config.allowedIPs = ips;
    notifyListeners();
  }

  void toggleAutoStart() {
    _config.autoStart = !_config.autoStart;
    notifyListeners();
  }

  void toggleShowNotifications() {
    _config.showNotifications = !_config.showNotifications;
    notifyListeners();
  }
}
