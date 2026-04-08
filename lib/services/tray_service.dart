import 'dart:io';
import 'dart:async';

import 'package:system_tray/system_tray.dart';

import '../config/constants.dart';
import '../providers/locale_provider.dart';

typedef TrayActionCallback = FutureOr<void> Function();

class TrayService {
  final TrayActionCallback? onStartService;
  final TrayActionCallback? onShowWindow;
  final TrayActionCallback? onExit;

  final SystemTray _systemTray = SystemTray();
  bool _isServerRunning = false;
  bool _trayReady = false;
  LocaleProvider? _localeProvider;

  TrayService({this.onStartService, this.onShowWindow, this.onExit});

  /// Set the locale provider for localized strings
  void setLocaleProvider(LocaleProvider provider) {
    _localeProvider = provider;
    provider.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (_trayReady) {
      _buildMenu();
    }
  }

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
        isTemplate: Platform.isMacOS,
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
    if (Platform.isMacOS) {
      return 'assets/icons/menubar_bell_template.png';
    }
    return 'assets/icons/tray_icon.png';
  }

  bool get _isChinese {
    final locale = _localeProvider?.locale;
    if (locale == null) {
      // Default to system locale
      return Platform.localeName.startsWith('zh');
    }
    return locale.languageCode == 'zh';
  }

  String _l10n(String en, String zh) => _isChinese ? zh : en;

  Future<void> _buildMenu() async {
    try {
      final menu = Menu();
      // Build menu items list
      final menuItems = <MenuItemBase>[];

      // Open main window
      menuItems.add(
        MenuItemLabel(
          label: _l10n('Open Main Window', '打开主界面'),
          onClicked: (_) => _runAction(onShowWindow),
        ),
      );

      menuItems.add(MenuSeparator());

      // Service control: stopping is not exposed to users.
      if (!_isServerRunning && onStartService != null) {
        menuItems.add(
          MenuItemLabel(
            label: _l10n('Start Service', '启动服务'),
            onClicked: (_) => _runAction(onStartService),
          ),
        );
        menuItems.add(MenuSeparator());
      }

      // Exit
      menuItems.add(
        MenuItemLabel(
          label: _l10n('Exit', '退出'),
          onClicked: (_) => _runAction(onExit),
        ),
      );

      await menu.buildFrom(menuItems);
      await _systemTray.setContextMenu(menu);
      await _systemTray.setToolTip(
        _isServerRunning
            ? _l10n(
                '${AppConstants.appName} (Service Running)',
                '${AppConstants.appName}（服务运行中）',
              )
            : _l10n(
                '${AppConstants.appName} (Service Not Running)',
                '${AppConstants.appName}（服务未运行）',
              ),
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
    _localeProvider?.removeListener(_onLocaleChanged);
    try {
      await _systemTray.destroy();
    } catch (e) {
      stderr.writeln('Failed to destroy tray: $e');
    }
  }
}
