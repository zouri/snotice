import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/reminder.dart';
import '../../../providers/reminder_provider.dart';

class RemindersTab extends StatelessWidget {
  const RemindersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        final activeReminders = reminderProvider.activeReminders;

        if (activeReminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.alarm_off,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noActiveReminders,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: activeReminders.length,
          itemBuilder: (context, index) {
            final reminder = activeReminders[index];
            return _ReminderCard(
              reminder: reminder,
              onRemove: () => reminderProvider.removeReminder(reminder.id),
            );
          },
        );
      },
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.onRemove});

  final Reminder reminder;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reminder.type == 'flash'
              ? colorScheme.tertiaryContainer
              : colorScheme.primaryContainer,
          child: Icon(
            reminder.type == 'flash' ? Icons.fullscreen : Icons.notifications,
            color: reminder.type == 'flash'
                ? colorScheme.tertiary
                : colorScheme.primary,
          ),
        ),
        title: Text(
          reminder.title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.body, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              reminder.timeRemaining,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.cancel, color: colorScheme.error),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
