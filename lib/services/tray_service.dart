import 'dart:io';
import 'dart:async';

import 'package:system_tray/system_tray.dart';

import '../config/constants.dart';
import '../providers/locale_provider.dart';

typedef TrayActionCallback = FutureOr<void> Function();
typedef TemplateActionCallback = FutureOr<void> Function(String templateId);

class TrayService {
  final TrayActionCallback? onStartStop;
  final TrayActionCallback? onShowWindow;
  final TrayActionCallback? onOpenSettings;
  final TrayActionCallback? onToggleUpcomingWindow;
  final TrayActionCallback? onExit;
  final TemplateActionCallback? onCreateFromTemplate;

  final SystemTray _systemTray = SystemTray();
  bool _isServerRunning = false;
  bool _trayReady = false;
  LocaleProvider? _localeProvider;

  TrayService({
    this.onStartStop,
    this.onShowWindow,
    this.onOpenSettings,
    this.onToggleUpcomingWindow,
    this.onExit,
    this.onCreateFromTemplate,
  });

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
      final actionLabel = _isServerRunning
          ? _l10n('Stop Service', '停止服务')
          : _l10n('Start Service', '启动服务');

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

      // Quick reminders sub-menu
      if (onCreateFromTemplate != null) {
        menuItems.add(
          SubMenu(
            label: _l10n('⚡ Quick Reminders', '⚡ 快速提醒'),
            children: [
              MenuItemLabel(
                label: _l10n('☕ Break (25 min)', '☕ 休息 (25分钟)'),
                onClicked: (_) => _runTemplateAction('break_25'),
              ),
              MenuItemLabel(
                label: _l10n('📌 Meeting (15 min)', '📌 会议 (15分钟)'),
                onClicked: (_) => _runTemplateAction('meeting_15'),
              ),
              MenuItemLabel(
                label: _l10n('💊 Medicine (4h)', '💊 吃药 (4小时)'),
                onClicked: (_) => _runTemplateAction('medicine_4h'),
              ),
              MenuItemLabel(
                label: _l10n('🍅 Pomodoro (25 min)', '🍅 番茄钟 (25分钟)'),
                onClicked: (_) => _runTemplateAction('pomodoro'),
              ),
              MenuItemLabel(
                label: _l10n('💧 Water (30 min)', '💧 喝水 (30分钟)'),
                onClicked: (_) => _runTemplateAction('water'),
              ),
              MenuItemLabel(
                label: _l10n('🧘 Stretch (45 min)', '🧘 伸展 (45分钟)'),
                onClicked: (_) => _runTemplateAction('stretch'),
              ),
            ],
          ),
        );

        menuItems.add(MenuSeparator());
      }

      if (onToggleUpcomingWindow != null) {
        menuItems.add(
          MenuItemLabel(
            label: _l10n('Toggle Floating Window', '切换悬浮窗'),
            onClicked: (_) => _runAction(onToggleUpcomingWindow),
          ),
        );
        menuItems.add(MenuSeparator());
      }

      // Service control
      if (onStartStop != null) {
        menuItems.add(
          MenuItemLabel(
            label: actionLabel,
            onClicked: (_) => _runAction(onStartStop),
          ),
        );
      }

      // Settings
      if (onOpenSettings != null) {
        menuItems.add(
          MenuItemLabel(
            label: _l10n('Settings', '设置'),
            onClicked: (_) => _runAction(onOpenSettings),
          ),
        );
      }

      menuItems.add(MenuSeparator());

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
            ? _l10n('${AppConstants.appName} (Service Running)', '${AppConstants.appName}（服务运行中）')
            : _l10n('${AppConstants.appName} (Service Not Running)', '${AppConstants.appName}（服务未运行）'),
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

  Future<void> _runTemplateAction(String templateId) async {
    if (onCreateFromTemplate == null) {
      return;
    }

    try {
      await onCreateFromTemplate!(templateId);
    } catch (e) {
      stderr.writeln('Template action failed: $e');
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
