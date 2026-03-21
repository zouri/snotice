import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_text_styles.dart';
import '../main/shell_dimensions.dart';

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({
    required this.showFlash,
    required this.showBarrage,
    required this.showSound,
    required this.onShowFlashChanged,
    required this.onShowBarrageChanged,
    required this.onShowSoundChanged,
    super.key,
  });

  final bool showFlash;
  final bool showBarrage;
  final bool showSound;
  final ValueChanged<bool> onShowFlashChanged;
  final ValueChanged<bool> onShowBarrageChanged;
  final ValueChanged<bool> onShowSoundChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationSettings,
              style: AppTextStyles.cardTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.notificationModesDesc,
              style: AppTextStyles.bodySm.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _SwitchRow(
              title: l10n.showFlash,
              subtitle: l10n.showFlashDesc,
              value: showFlash,
              onChanged: onShowFlashChanged,
            ),
            const Divider(height: 18),
            _SwitchRow(
              title: l10n.showBarrage,
              subtitle: l10n.showBarrageDesc,
              value: showBarrage,
              onChanged: onShowBarrageChanged,
            ),
            const Divider(height: 18),
            _SwitchRow(
              title: l10n.showSound,
              subtitle: l10n.showSoundDesc,
              value: showSound,
              onChanged: onShowSoundChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMd.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySm.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
