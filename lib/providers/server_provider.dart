import 'package:flutter/foundation.dart';
import '../services/http_server_service.dart';
import '../models/app_config.dart';

class ServerProvider with ChangeNotifier {
  HttpServerService? _httpServerService;

  bool get isRunning => _httpServerService?.isRunning ?? false;
  int? get port => _httpServerService?.port;

  void setHttpServerService(HttpServerService service) {
    _httpServerService = service;
  }

  Future<void> start() async {
    if (_httpServerService == null) return;
    await _httpServerService!.start();
    notifyListeners();
  }

  Future<void> stop() async {
    if (_httpServerService == null) return;
    await _httpServerService!.stop();
    notifyListeners();
  }

  void updateConfig(AppConfig config) {
    _httpServerService?.updateConfig(config);
  }
}
