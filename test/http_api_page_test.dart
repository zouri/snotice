import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snotice_new/l10n/app_localizations.dart';
import 'package:snotice_new/models/app_config.dart';
import 'package:snotice_new/providers/config_provider.dart';
import 'package:snotice_new/ui/screens/http_api_page.dart';

Widget _buildTestApp({
  required Locale locale,
  required ConfigProvider configProvider,
}) {
  return MultiProvider(
    providers: [ChangeNotifierProvider.value(value: configProvider)],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const HttpApiPage(),
    ),
  );
}

Future<void> _scrollUntilTextVisible(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    260,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HttpApiPage localization', () {
    testWidgets('renders English labels', (tester) async {
      final configProvider = ConfigProvider()
        ..updateConfig(AppConfig(port: 8642));

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en', 'US'),
          configProvider: configProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('API Overview'), findsOneWidget);
      expect(find.text('Base URL'), findsOneWidget);
      expect(find.text('Authentication'), findsOneWidget);
      expect(find.text('http://localhost:8642'), findsOneWidget);
      expect(
        find.text('No authentication currently. Any reachable IP can call this API.'),
        findsOneWidget,
      );
      await _scrollUntilTextVisible(tester, 'Endpoint List');
      expect(find.text('Endpoint List'), findsOneWidget);
    });

    testWidgets('renders Chinese labels', (tester) async {
      final configProvider = ConfigProvider()
        ..updateConfig(AppConfig(port: 8642));

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('zh', 'CN'),
          configProvider: configProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('API 概览'), findsOneWidget);
      expect(find.text('Base URL'), findsOneWidget);
      expect(find.text('认证方式'), findsOneWidget);
      expect(find.text('http://localhost:8642'), findsOneWidget);
      expect(find.text('当前无鉴权，任何可访问到该服务的 IP 都可以调用。'), findsOneWidget);
      await _scrollUntilTextVisible(tester, '接口清单');
      expect(find.text('接口清单'), findsOneWidget);
    });
  });
}
