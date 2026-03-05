import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../main/shell_dimensions.dart';

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({
    required this.showNotifications,
    required this.onShowNotificationsChanged,
    super.key,
  });

  final bool showNotifications;
  final ValueChanged<bool> onShowNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationSettings,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: ShellDimensions.cardTitleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.showNotifications,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: ShellDimensions.bodySize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l10n.showNotificationsDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: ShellDimensions.metaSize,
                ),
              ),
              value: showNotifications,
              onChanged: onShowNotificationsChanged,
            ),
          ],
        ),
      ),
    );
  }
}
