import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import '../config/constants.dart';

class TrayService {
  final VoidCallback? onStartStop;
  final VoidCallback? onShowWindow;
  final VoidCallback? onExit;

  final SystemTray _systemTray = SystemTray();

  TrayService({this.onStartStop, this.onShowWindow, this.onExit});

  Future<void> initialize() async {
    await _initTray();
    await _initMenu();
  }

  Future<void> _initTray() async {
    final String path;

    if (Platform.isWindows) {
      path = 'assets/icons/tray_icon.ico';
    } else if (Platform.isMacOS) {
      path = 'assets/icons/tray_icon.png';
    } else {
      path = 'assets/icons/tray_icon.png';
    }

    try {
      await _systemTray.initSystemTray(
        title: AppConstants.appName,
        iconPath: path,
      );

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == 'kSystemTrayEventClick' ||
            eventName == 'kSystemTrayEventRightClick') {
          _systemTray.popUpContextMenu();
        }
      });
    } catch (e) {
      print('Failed to initialize system tray: $e');
    }
  }

  Future<void> _initMenu() async {
    try {
      final menu = Menu();
      await _systemTray.setContextMenu(menu);
    } catch (e) {
      print('Failed to initialize menu: $e');
    }
  }

  void updateMenu(bool isServerRunning) {
    try {
      final menu = Menu();

      final actionLabel = isServerRunning ? 'Stop Server' : 'Start Server';

      menu.buildFrom([
        MenuItemLabel(label: actionLabel),
        MenuSeparator(),
        MenuItemLabel(label: 'Show Window'),
        MenuSeparator(),
        MenuItemLabel(label: 'Exit'),
      ]);

      _systemTray.setContextMenu(menu);
    } catch (e) {
      print('Failed to update menu: $e');
    }
  }

  void dispose() {
    try {
      _systemTray.destroy();
    } catch (e) {
      print('Failed to destroy tray: $e');
    }
  }
}
