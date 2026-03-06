import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/locale_provider.dart';
import '../main/shell_dimensions.dart';

class LanguageSettingsCard extends StatelessWidget {
  const LanguageSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: ShellDimensions.cardTitleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
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
