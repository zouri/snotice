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

      expect(find.text('Endpoints'), findsOneWidget);
      expect(find.text('Examples'), findsOneWidget);
      expect(find.text('POST /api/notify (normal)'), findsOneWidget);
      expect(find.text('POST /api/notify (flash)'), findsOneWidget);
      expect(find.textContaining('"title":"Hello"'), findsOneWidget);
      expect(find.textContaining('"body":"From SNotice"'), findsOneWidget);
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

      expect(find.text('接口地址'), findsOneWidget);
      expect(find.text('请求示例'), findsOneWidget);
      expect(find.text('POST /api/notify（普通通知）'), findsOneWidget);
      expect(find.text('POST /api/notify（闪屏）'), findsOneWidget);
      expect(find.textContaining('"title":"你好"'), findsOneWidget);
      expect(find.textContaining('"body":"来自 SNotice"'), findsOneWidget);
    });
  });
}
