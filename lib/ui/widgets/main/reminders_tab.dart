import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/reminder.dart';
import '../../../providers/reminder_provider.dart';

class RemindersTab extends StatelessWidget {
  const RemindersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        final activeReminders = reminderProvider.activeReminders;

        if (activeReminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.alarm_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No active reminders',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reminder.type == 'flash'
              ? Colors.orange.withValues(alpha: 0.1)
              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(
            reminder.type == 'flash' ? Icons.fullscreen : Icons.notifications,
            color: reminder.type == 'flash'
                ? Colors.orange
                : Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.body, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              reminder.timeRemaining,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
