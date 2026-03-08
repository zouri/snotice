import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'config/constants.dart';
import 'l10n/app_localizations.dart';
import 'overlay_main.dart' as overlay;
import 'providers/config_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/server_provider.dart';
import 'services/config_service.dart';
import 'services/flash_overlay_service.dart';
import 'services/http_server_service.dart';
import 'services/logger_service.dart';
import 'services/notification_service.dart';
import 'services/tray_service.dart';
import 'providers/theme_provider.dart';
import 'theme/theme.dart';
import 'ui/screens/app_shell.dart';

// 全局导航器 Key，用于在 main.dart 中访问导航
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    final windowArguments = await _resolveCurrentWindowArguments(args);
    final windowType = windowArguments['windowType'] as String?;

    // 仅在 multi_window 子窗口且明确标记为 flash 时进入 overlay 入口
    if (windowType == 'flash') {
      overlay.overlayMain(args);
      return;
    }
  }

  // 正常启动主应用
  await _startMainApp();
}

Future<Map<String, dynamic>> _resolveCurrentWindowArguments(
  List<String> args,
) async {
  if (args.length < 3 || args.first != 'multi_window') {
    return {};
  }

  final parsedFromEntrypoint = _parseWindowArguments(args[2]);
  if (parsedFromEntrypoint.isNotEmpty) {
    return parsedFromEntrypoint;
  }

  try {
    final controller = await WindowController.fromCurrentEngine();
    return _parseWindowArguments(controller.arguments);
  } catch (_) {
    // Fallback to empty arguments when current engine context is unavailable.
    return {};
  }
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

  final notificationService = NotificationService(
    loggerService,
    flashOverlayService,
  );
  await notificationService.initialize();

  final httpServerService = HttpServerService(
    notificationService: notificationService,
    logger: loggerService,
    config: config,
  );

  final configProvider = ConfigProvider()..updateConfig(config);
  final serverProvider = ServerProvider(httpServerService);
  final themeProvider = ThemeProvider();
  await themeProvider.load();
  final localeProvider = LocaleProvider();
  await localeProvider.load();

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
    onExit: () => _exitApplication(
      loggerService: loggerService,
      serverProvider: serverProvider,
      trayService: trayService,
    ),
  );

  serverProvider.addListener(() {
    unawaited(trayService.updateMenu(serverProvider.isRunning));
  });

  // Connect locale provider to tray service for localized menu
  trayService.setLocaleProvider(localeProvider);

  await trayService.initialize(isServerRunning: serverProvider.isRunning);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: configProvider),
        ChangeNotifierProvider.value(value: serverProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: loggerService),
        Provider.value(value: notificationService),
        Provider.value(value: configService),
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

Future<void> _exitApplication({
  required LoggerService loggerService,
  required ServerProvider serverProvider,
  required TrayService trayService,
}) async {
  loggerService.info('Exiting application');

  try {
    if (serverProvider.isRunning) {
      await serverProvider.stop();
    }
  } catch (e) {
    loggerService.error('Failed to stop server during exit: $e');
  }

  await trayService.dispose();
  exit(0);
}

class SNoticeApp extends StatelessWidget {
  const SNoticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.mode,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppShell(),
        );
      },
    );
  }
}
