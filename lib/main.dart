import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'config/constants.dart';
import 'overlay_main.dart' as overlay;
import 'upcoming_window_main.dart' as upcoming;
import 'providers/config_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/server_provider.dart';
import 'providers/template_provider.dart';
import 'services/config_service.dart';
import 'services/flash_overlay_service.dart';
import 'services/http_server_service.dart';
import 'services/logger_service.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';
import 'services/stats_service.dart';
import 'services/template_service.dart';
import 'services/tray_service.dart';
import 'services/upcoming_window_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/settings_screen.dart';

// 全局导航器 Key，用于在 main.dart 中访问导航
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    try {
      final controller = await WindowController.fromCurrentEngine();
      final arguments = _parseWindowArguments(controller.arguments);
      final windowType = arguments['windowType'] as String?;

      // 即将到期提醒悬浮窗入口（独立窗口）
      if (windowType == 'upcoming') {
        upcoming.upcomingWindowMain(args);
        return;
      }

      // 非 macOS 使用 Flutter 覆盖窗口实现闪屏
      if (!Platform.isMacOS &&
          (windowType == 'flash' || arguments.containsKey('color'))) {
        overlay.overlayMain(args);
        return;
      }
    } catch (_) {
      // Fallback to main app when multi-window context is unavailable.
    }
  }

  // 正常启动主应用
  await _startMainApp();
}

Map<String, dynamic> _parseWindowArguments(String rawArguments) {
  if (rawArguments.isEmpty) {
    return {};
  }

  try {
    final decoded = jsonDecode(rawArguments);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {
    // Ignore invalid arguments.
  }

  return {};
}

Future<void> _startMainApp() async {
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    await windowManager.ensureInitialized();
  }

  final loggerService = LoggerService();
  loggerService.info('Starting SNotice...');

  final configService = ConfigService(loggerService);
  final config = await configService.loadConfig();
  loggerService.info('Config loaded: ${config.toJson()}');

  // 创建 FlashOverlayService
  final flashOverlayService = FlashOverlayService(loggerService);

  // 创建 SoundService
  final soundService = SoundService(loggerService);

  final notificationService = NotificationService(
    loggerService,
    flashOverlayService,
  );
  await notificationService.initialize();
  await notificationService.requestPermissions();

  final httpServerService = HttpServerService(
    notificationService: notificationService,
    logger: loggerService,
    config: config,
  );

  // 创建 StatsService
  final statsService = StatsService(loggerService);

  // 创建 TemplateService 和 TemplateProvider
  final templateService = TemplateService(loggerService);

  final configProvider = ConfigProvider()..updateConfig(config);
  final serverProvider = ServerProvider(httpServerService);
  final reminderProvider = ReminderProvider(
    loggerService,
    notificationService,
    statsService,
  );
  final templateProvider = TemplateProvider(templateService, loggerService);
  final upcomingWindowService = UpcomingWindowService(loggerService);

  late final TrayService trayService;
  trayService = TrayService(
    onStartStop: () async {
      if (serverProvider.isRunning) {
        await serverProvider.stop();
      } else {
        await serverProvider.start();
      }
    },
    onShowWindow: () => _showMainWindow(loggerService),
    onOpenSettings: () => _openSettings(loggerService),
    onCreateFromTemplate: (templateId) async {
      final template = templateProvider.getById(templateId);
      if (template != null) {
        reminderProvider.createFromTemplate(template);
        loggerService.info('Created reminder from tray: ${template.name}');
      }
    },
    onToggleUpcomingWindow: () async {
      await upcomingWindowService.toggleWindow();
    },
    onExit: () => _exitApplication(
      loggerService: loggerService,
      serverProvider: serverProvider,
      trayService: trayService,
      soundService: soundService,
    ),
  );

  serverProvider.addListener(() {
    unawaited(trayService.updateMenu(serverProvider.isRunning));
  });

  await trayService.initialize(isServerRunning: serverProvider.isRunning);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: configProvider),
        ChangeNotifierProvider.value(value: serverProvider),
        ChangeNotifierProvider.value(value: reminderProvider),
        ChangeNotifierProvider.value(value: templateProvider),
        Provider.value(value: loggerService),
        Provider.value(value: notificationService),
        Provider.value(value: configService),
        Provider.value(value: statsService),
        Provider.value(value: soundService),
        Provider.value(value: upcomingWindowService),
      ],
      child: const SNoticeApp(),
    ),
  );

  if (config.autoStart) {
    await serverProvider.start();
    if (!serverProvider.isRunning && serverProvider.lastError != null) {
      loggerService.warning(
        'Server auto-start failed: ${serverProvider.lastError}',
      );
    }
  }
}

Future<void> _showMainWindow(LoggerService loggerService) async {
  try {
    if (await windowManager.isMinimized()) {
      await windowManager.restore();
    }
    await windowManager.show();
    await windowManager.focus();
  } catch (e) {
    loggerService.error('Failed to show main window: $e');
  }
}

Future<void> _openSettings(LoggerService loggerService) async {
  try {
    await _showMainWindow(loggerService);
    // 通过全局导航器打开设置页面
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  } catch (e) {
    loggerService.error('Failed to open settings: $e');
  }
}

Future<void> _exitApplication({
  required LoggerService loggerService,
  required ServerProvider serverProvider,
  required TrayService trayService,
  required SoundService soundService,
}) async {
  loggerService.info('Exiting application');

  try {
    if (serverProvider.isRunning) {
      await serverProvider.stop();
    }
  } catch (e) {
    loggerService.error('Failed to stop server during exit: $e');
  }

  soundService.dispose();
  await trayService.dispose();
  exit(0);
}

class SNoticeApp extends StatelessWidget {
  const SNoticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
