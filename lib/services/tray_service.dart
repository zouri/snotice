import 'dart:io';
import 'dart:async';

import 'package:system_tray/system_tray.dart';

import '../config/constants.dart';

typedef TrayActionCallback = FutureOr<void> Function();

class TrayService {
  final TrayActionCallback? onStartStop;
  final TrayActionCallback? onShowWindow;
  final TrayActionCallback? onExit;

  final SystemTray _systemTray = SystemTray();
  bool _isServerRunning = false;
  bool _trayReady = false;

  TrayService({this.onStartStop, this.onShowWindow, this.onExit});

  Future<void> initialize({bool isServerRunning = false}) async {
    _isServerRunning = isServerRunning;
    await _initTray();
    if (_trayReady) {
      await _buildMenu();
    }
  }

  Future<void> _initTray() async {
    final path = _resolveTrayIconPath();

    try {
      await _systemTray.initSystemTray(
        title: Platform.isMacOS ? '' : null,
        iconPath: path,
        toolTip: AppConstants.appName,
      );

      _trayReady = true;

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventDoubleClick) {
          _runAction(onShowWindow);
          return;
        }

        if ((eventName == kSystemTrayEventClick ||
                eventName == kSystemTrayEventRightClick) &&
            !Platform.isLinux) {
          _systemTray.popUpContextMenu();
        }
      });
    } catch (e) {
      stderr.writeln('Failed to initialize system tray: $e');
    }
  }

  String _resolveTrayIconPath() {
    if (Platform.isWindows) {
      return 'assets/icons/tray_icon.ico';
    }
    return 'assets/icons/tray_icon.png';
  }

  Future<void> _buildMenu() async {
    try {
      final menu = Menu();

      final actionLabel = _isServerRunning ? '停止服务' : '启动服务';

      await menu.buildFrom([
        MenuItemLabel(
          label: '打开主界面',
          onClicked: (_) => _runAction(onShowWindow),
        ),
        if (onStartStop != null)
          MenuItemLabel(
            label: actionLabel,
            onClicked: (_) => _runAction(onStartStop),
          ),
        MenuSeparator(),
        MenuItemLabel(label: '退出', onClicked: (_) => _runAction(onExit)),
      ]);

      await _systemTray.setContextMenu(menu);
      await _systemTray.setToolTip(
        _isServerRunning
            ? '${AppConstants.appName}（服务运行中）'
            : '${AppConstants.appName}（服务未运行）',
      );
    } catch (e) {
      stderr.writeln('Failed to build tray menu: $e');
    }
  }

  Future<void> updateMenu(bool isServerRunning) async {
    _isServerRunning = isServerRunning;
    if (_trayReady) {
      await _buildMenu();
    }
  }

  Future<void> _runAction(TrayActionCallback? action) async {
    if (action == null) {
      return;
    }

    try {
      await action();
    } catch (e) {
      stderr.writeln('Tray action failed: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _systemTray.destroy();
    } catch (e) {
      stderr.writeln('Failed to destroy tray: $e');
    }
  }
}
