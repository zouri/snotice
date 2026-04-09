import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snotice_new/l10n/app_localizations.dart';
import 'package:snotice_new/models/app_config.dart';
import 'package:snotice_new/providers/config_provider.dart';
import 'package:snotice_new/providers/server_provider.dart';
import 'package:snotice_new/services/flash_overlay_service.dart';
import 'package:snotice_new/services/http_server_service.dart';
import 'package:snotice_new/services/logger_service.dart';
import 'package:snotice_new/services/notification_service.dart';
import 'package:snotice_new/ui/screens/notification_test_page.dart';

Widget _buildTestApp({required Locale locale, required AppConfig config}) {
  final logger = LoggerService();
  final serverProvider = ServerProvider(
    HttpServerService(
      notificationService: NotificationService(
        logger,
        FlashOverlayService(logger),
        config,
      ),
      logger: logger,
      config: config,
    ),
  );
  final configProvider = ConfigProvider()..updateConfig(config);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: configProvider),
      ChangeNotifierProvider.value(value: serverProvider),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const NotificationTestPage(),
    ),
  );
}

void _setLargeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('NotificationTestPage', () {
    testWidgets('renders English preview and curl output', (tester) async {
      _setLargeSurface(tester);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en', 'US'),
          config: AppConfig(port: 8642),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification Test Lab'), findsOneWidget);
      expect(find.text('Copy curl'), findsOneWidget);
      expect(find.text('http://localhost:8642/api/notify'), findsOneWidget);
      expect(find.textContaining('"title": "Build Complete"'), findsOneWidget);
      expect(
        find.textContaining('curl -X POST http://localhost:8642/api/notify'),
        findsOneWidget,
      );
    });

    testWidgets('switches to barrage mode in Chinese', (tester) async {
      _setLargeSurface(tester);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('zh', 'CN'),
          config: AppConfig(port: 9527),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('通知测试台'), findsOneWidget);
      expect(find.text('弹幕'), findsOneWidget);

      await tester.tap(find.text('弹幕'));
      await tester.pumpAndSettle();

      expect(find.text('文字颜色'), findsOneWidget);
      expect(find.text('速度（像素/秒）'), findsOneWidget);
      expect(find.text('轨道'), findsOneWidget);
      expect(find.textContaining('"category": "barrage"'), findsOneWidget);
      expect(find.textContaining('"barrageLane": "top"'), findsOneWidget);
    });

    testWidgets('shows preview errors for invalid JSON payload', (
      tester,
    ) async {
      _setLargeSurface(tester);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en', 'US'),
          config: AppConfig(port: 8642),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.bySemanticsLabel('Payload (JSON object, optional)'),
        '{oops',
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'Fix the request errors below before sending or copying.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('Payload must be valid JSON.'),
        findsOneWidget,
      );
    });
  });
}
