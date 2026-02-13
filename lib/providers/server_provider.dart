import 'package:flutter/foundation.dart';
import '../models/app_config.dart';
import '../services/http_server_service.dart';

class ServerProvider with ChangeNotifier {
  ServerProvider(this._httpServerService);

  final HttpServerService _httpServerService;

  bool get isRunning => _httpServerService.isRunning;

  Future<void> start() async {
    await _httpServerService.start();
    notifyListeners();
  }

  Future<void> stop() async {
    await _httpServerService.stop();
    notifyListeners();
  }

  void updateConfig(AppConfig config) {
    _httpServerService.updateConfig(config);
  }
}
