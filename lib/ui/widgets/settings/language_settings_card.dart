import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/locale_provider.dart';
import '../../../theme/app_text_styles.dart';
import '../main/shell_dimensions.dart';

class LanguageSettingsCard extends StatelessWidget {
  const LanguageSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;
    final colorScheme = Theme.of(context).colorScheme;
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: ShellDimensions.cardTitleSize,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isZh ? '切换界面展示语言' : 'Switch the UI language',
              style: AppTextStyles.bodySm.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Locale?>(
              initialValue: currentLocale,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: LocaleProvider.localeOptions.map((option) {
                return DropdownMenuItem<Locale?>(
                  value: option.locale,
                  child: Text(option.getLabel(currentLocale)),
                );
              }).toList(),
              onChanged: (locale) {
                localeProvider.setLocale(locale);
              },
            ),
          ],
        ),
      ),
    );
  }
}
