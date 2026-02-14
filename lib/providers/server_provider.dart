import 'dart:io';

import 'package:flutter/foundation.dart';
import '../models/app_config.dart';
import '../services/http_server_service.dart';

class ServerProvider with ChangeNotifier {
  ServerProvider(this._httpServerService);

  final HttpServerService _httpServerService;
  String? _lastError;

  bool get isRunning => _httpServerService.isRunning;
  String? get lastError => _lastError;

  Future<void> start() async {
    _lastError = null;

    try {
      await _httpServerService.start();
    } on SocketException catch (e) {
      _lastError = _formatSocketError(e);
    } catch (e) {
      _lastError = '启动服务失败：$e';
    }

    notifyListeners();
  }

  Future<void> stop() async {
    _lastError = null;

    try {
      await _httpServerService.stop();
    } catch (e) {
      _lastError = '停止服务失败：$e';
    }

    notifyListeners();
  }

  void updateConfig(AppConfig config) {
    _httpServerService.updateConfig(config);
  }

  void clearLastError() {
    if (_lastError == null) {
      return;
    }

    _lastError = null;
    notifyListeners();
  }

  String _formatSocketError(SocketException error) {
    final code = error.osError?.errorCode;
    final message = error.osError?.message ?? error.message;

    if (code == 48 ||
        code == 98 ||
        code == 10048 ||
        message.contains('Address already in use')) {
      return '端口 ${_httpServerService.port} 已被占用，请关闭占用进程或在设置中修改端口。';
    }

    return '启动服务失败：$message';
  }
}
