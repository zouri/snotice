import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationSettings,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.showNotifications),
              subtitle: Text(l10n.showNotificationsDesc),
              value: showNotifications,
              onChanged: onShowNotificationsChanged,
            ),
          ],
        ),
      ),
    );
  }
}
