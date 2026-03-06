import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import '../main/shell_dimensions.dart';

class ThemeSettingsCard extends StatelessWidget {
  const ThemeSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    String labelFor(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return l10n.themeModeSystem;
        case ThemeMode.light:
          return l10n.themeModeLight;
        case ThemeMode.dark:
          return l10n.themeModeDark;
      }
    }

    IconData iconFor(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return Icons.settings_suggest_outlined;
        case ThemeMode.light:
          return Icons.wb_sunny_outlined;
        case ThemeMode.dark:
          return Icons.dark_mode_outlined;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(ShellDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.themeTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: ShellDimensions.cardTitleSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.themeSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: ShellDimensions.bodySmallSize,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ThemeMode.values.map((mode) {
                  final selected = themeProvider.mode == mode;
                  final foreground = selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant;

                  return ChoiceChip(
                    showCheckmark: false,
                    selected: selected,
                    onSelected: (active) {
                      if (active) {
                        themeProvider.setMode(mode);
                      }
                    },
                    avatar: Icon(iconFor(mode), size: 16, color: foreground),
                    label: Text(
                      labelFor(mode),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: ShellDimensions.metaSize,
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: colorScheme.surface,
                    side: BorderSide(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                    shape: const StadiumBorder(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
