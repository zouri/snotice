import 'package:flutter/material.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Notifications'),
              subtitle: const Text('Display system notifications'),
              value: showNotifications,
              onChanged: onShowNotificationsChanged,
            ),
          ],
        ),
      ),
    );
  }
}
