import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snotice_new/l10n/app_localizations.dart';
import 'package:snotice_new/providers/theme_provider.dart';
import 'package:snotice_new/ui/widgets/settings/theme_settings_card.dart';

Widget _buildThemeCardApp(Locale locale) {
  return ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const Scaffold(body: ThemeSettingsCard()),
    ),
  );
}

void main() {
  group('ThemeSettingsCard localization', () {
    testWidgets('renders English texts', (tester) async {
      await tester.pumpWidget(_buildThemeCardApp(const Locale('en', 'US')));
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light, Dark, or follow system'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('renders Chinese texts', (tester) async {
      await tester.pumpWidget(_buildThemeCardApp(const Locale('zh', 'CN')));
      await tester.pumpAndSettle();

      expect(find.text('外观主题'), findsOneWidget);
      expect(find.text('可切换浅色、深色或跟随系统'), findsOneWidget);
      expect(find.text('跟随系统'), findsOneWidget);
      expect(find.text('浅色'), findsOneWidget);
      expect(find.text('深色'), findsOneWidget);
    });
  });
}
