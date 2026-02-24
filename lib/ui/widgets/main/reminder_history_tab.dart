import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/reminder.dart';
import '../../../providers/reminder_provider.dart';

class ReminderHistoryTab extends StatelessWidget {
  const ReminderHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        final expiredReminders = reminderProvider.expiredReminders;

        if (expiredReminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  l10n.noReminderHistory,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                onPressed: reminderProvider.clearExpired,
                icon: const Icon(Icons.delete_sweep),
                label: Text(l10n.clearHistory),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: expiredReminders.length,
                itemBuilder: (context, index) {
                  return _HistoryCard(reminder: expiredReminders[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.check_circle, color: Colors.grey[600]),
        ),
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          reminder.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatHistoryTime(context, reminder.createdAt),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }

  String _formatHistoryTime(BuildContext context, DateTime time) {
    final l10n = AppLocalizations.of(context)!;
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    }
    if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    }
    if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    }
    return '${time.day}/${time.month}/${time.year}';
  }
}
