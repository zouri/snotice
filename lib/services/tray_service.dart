import 'dart:io';
import 'dart:async';

import 'package:system_tray/system_tray.dart';

import '../config/constants.dart';

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

  TrayService({
    this.onStartStop,
    this.onShowWindow,
    this.onOpenSettings,
    this.onToggleUpcomingWindow,
    this.onExit,
    this.onCreateFromTemplate,
  });

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

      // 构建菜单项列表 - 使用 MenuItemBase 作为类型
      final menuItems = <MenuItemBase>[];

      // 打开主界面
      menuItems.add(
        MenuItemLabel(
          label: '打开主界面',
          onClicked: (_) => _runAction(onShowWindow),
        ),
      );

      menuItems.add(MenuSeparator());

      // 快速提醒子菜单
      if (onCreateFromTemplate != null) {
        menuItems.add(
          SubMenu(
            label: '⚡ 快速提醒',
            children: [
              MenuItemLabel(
                label: '☕ 休息 (25分钟)',
                onClicked: (_) => _runTemplateAction('break_25'),
              ),
              MenuItemLabel(
                label: '📌 会议 (15分钟)',
                onClicked: (_) => _runTemplateAction('meeting_15'),
              ),
              MenuItemLabel(
                label: '💊 吃药 (4小时)',
                onClicked: (_) => _runTemplateAction('medicine_4h'),
              ),
              MenuItemLabel(
                label: '🍅 番茄钟 (25分钟)',
                onClicked: (_) => _runTemplateAction('pomodoro'),
              ),
              MenuItemLabel(
                label: '💧 喝水 (30分钟)',
                onClicked: (_) => _runTemplateAction('water'),
              ),
              MenuItemLabel(
                label: '🧘 伸展 (45分钟)',
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
            label: '切换悬浮窗',
            onClicked: (_) => _runAction(onToggleUpcomingWindow),
          ),
        );
        menuItems.add(MenuSeparator());
      }

      // 服务控制
      if (onStartStop != null) {
        menuItems.add(
          MenuItemLabel(
            label: actionLabel,
            onClicked: (_) => _runAction(onStartStop),
          ),
        );
      }

      // 设置
      if (onOpenSettings != null) {
        menuItems.add(
          MenuItemLabel(
            label: '设置',
            onClicked: (_) => _runAction(onOpenSettings),
          ),
        );
      }

      menuItems.add(MenuSeparator());

      // 退出
      menuItems.add(
        MenuItemLabel(label: '退出', onClicked: (_) => _runAction(onExit)),
      );

      await menu.buildFrom(menuItems);
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
    try {
      await _systemTray.destroy();
    } catch (e) {
      stderr.writeln('Failed to destroy tray: $e');
    }
  }
}
