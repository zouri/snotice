import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/constants.dart';
import 'overlay_main.dart' as overlay;
import 'providers/config_provider.dart';
import 'providers/log_provider.dart';
import 'providers/server_provider.dart';
import 'services/config_service.dart';
import 'services/flash_overlay_service.dart';
import 'services/http_server_service.dart';
import 'services/logger_service.dart';
import 'services/notification_service.dart';
import 'services/tray_service.dart';
import 'ui/main_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // macOS 已使用原生闪屏实现，不需要 desktop_multi_window 启动判断。
  if (!Platform.isMacOS) {
    final controller = await WindowController.fromCurrentEngine();

    // 检查是否为覆盖窗口（参数不为空且包含闪烁参数）
    if (controller.arguments.isNotEmpty) {
      try {
        final arguments = controller.arguments;
        // 如果参数包含color，说明是闪烁窗口
        if (arguments.contains('color')) {
          overlay.overlayMain(args);
          return;
        }
      } catch (_) {
        // 忽略解析错误
      }
    }
  }

  // 正常启动主应用
  await _startMainApp();
}

Future<void> _startMainApp() async {
  final loggerService = LoggerService();
  loggerService.info('Starting SNotice...');

  final configService = ConfigService(loggerService);
  final config = await configService.loadConfig();
  loggerService.info('Config loaded: ${config.toJson()}');

  // 创建 FlashOverlayService
  final flashOverlayService = FlashOverlayService(loggerService);

  final notificationService = NotificationService(
    loggerService,
    flashOverlayService,
  );
  await notificationService.initialize();
  await notificationService.requestPermissions();

  final logProvider = LogProvider(loggerService);
  final configProvider = ConfigProvider()..updateConfig(config);
  final serverProvider = ServerProvider();

  final httpServerService = HttpServerService(
    notificationService: notificationService,
    logger: loggerService,
    config: config,
  );
  serverProvider.setHttpServerService(httpServerService);

  final trayService = TrayService(
    onStartStop: () {
      if (serverProvider.isRunning) {
        serverProvider.stop();
      } else {
        serverProvider.start();
      }
    },
    onExit: () {
      loggerService.info('Exiting application');
    },
  );

  await trayService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: configProvider),
        ChangeNotifierProvider.value(value: logProvider),
        ChangeNotifierProvider.value(value: serverProvider),
        Provider.value(value: loggerService),
        Provider.value(value: notificationService),
        Provider.value(value: configService),
      ],
      child: const SNoticeApp(),
    ),
  );

  if (config.autoStart) {
    await serverProvider.start();
  }
}

class SNoticeApp extends StatelessWidget {
  const SNoticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
