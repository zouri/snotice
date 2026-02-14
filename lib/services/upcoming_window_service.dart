import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'logger_service.dart';

/// “即将到期提醒”独立悬浮窗管理服务
class UpcomingWindowService {
  final LoggerService _logger;
  WindowController? _windowController;
  bool _isVisible = false;

  UpcomingWindowService(this._logger);

  bool get isVisible => _isVisible;

  Future<bool> toggleWindow() async {
    if (_isVisible) {
      return hideWindow();
    }
    return showWindow();
  }

  Future<bool> showWindow() async {
    try {
      await _syncWindowController();
      _windowController ??= await _createWindowController();
      await _windowController!.show();
      _isVisible = true;
      _logger.info('Upcoming reminders window shown');
      return true;
    } catch (e) {
      _logger.error('Failed to show upcoming reminders window: $e');
      debugPrint('Failed to show upcoming reminders window: $e');
      _isVisible = false;
      return false;
    }
  }

  Future<bool> hideWindow() async {
    if (_windowController == null) {
      _isVisible = false;
      return true;
    }

    try {
      await _windowController!.hide();
      _isVisible = false;
      _logger.info('Upcoming reminders window hidden');
      return true;
    } catch (e) {
      _logger.error('Failed to hide upcoming reminders window: $e');
      debugPrint('Failed to hide upcoming reminders window: $e');
      return false;
    }
  }

  Future<WindowController> _createWindowController() async {
    final arguments = jsonEncode({'windowType': 'upcoming'});
    return WindowController.create(
      WindowConfiguration(hiddenAtLaunch: true, arguments: arguments),
    );
  }

  Future<void> _syncWindowController() async {
    if (_windowController == null) {
      return;
    }

    try {
      final windows = await WindowController.getAll();
      final exists = windows.any(
        (window) => window.windowId == _windowController!.windowId,
      );
      if (!exists) {
        _windowController = null;
        _isVisible = false;
      }
    } catch (e) {
      _logger.warning('Failed to sync upcoming reminders window state: $e');
    }
  }
}
