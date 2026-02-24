import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/reminder.dart';
import '../../../providers/reminder_provider.dart';
import '../../../services/stats_service.dart';

/// Right column: History and stats panel
class HistoryStatsPanel extends StatelessWidget {
  final Reminder? selectedReminder;

  const HistoryStatsPanel({
    super.key,
    this.selectedReminder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats summary
        _buildStatsSummary(context),
        const Divider(height: 1),
        // Trends chart
        _buildTrendsChart(context),
        const Divider(height: 1),
        // History or detail
        Expanded(
          child: selectedReminder != null
              ? _buildReminderDetail(context, selectedReminder!)
              : _buildHistoryList(context),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<ReminderStats>(
      future: context.read<StatsService>().calculate(),
      builder: (context, snapshot) {
        final stats = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.todayStats,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (stats == null)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      label: l10n.createdStat,
                      value: stats.totalCreated.toString(),
                      color: Colors.blue,
                    ),
                    _StatCard(
                      label: l10n.completedStat,
                      value: stats.totalTriggered.toString(),
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: l10n.completionRate,
                      value: '${(stats.completionRate * 100).toInt()}%',
                      color: Colors.purple,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendsChart(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 150,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.last7DaysTrend,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<DailyStats>>(
              future: context.read<StatsService>().getTrends(7),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(l10n.noData),
                  );
                }

                final trends = snapshot.data!;
                final maxCreated = trends
                    .map((t) => t.created)
                    .reduce((a, b) => a > b ? a : b);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: trends.map((trend) {
                    final height = maxCreated > 0
                        ? (trend.created / maxCreated)
                        : 0.0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${trend.created}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 60 * height.clamp(0.1, 1.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatWeekday(l10n, trend.date.weekday),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        final history = provider.expiredReminders.reversed.take(20).toList();

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.history,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: () => provider.clearExpired(),
                      child: Text(l10n.clearAll),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            Expanded(
              child: history.isEmpty
                  ? _buildEmptyHistory(context, l10n)
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final reminder = history[index];
                        return _HistoryItem(reminder: reminder, l10n: l10n);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyHistory(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.noHistory,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderDetail(BuildContext context, Reminder reminder) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.reminderDetail,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(label: l10n.labelTitle, value: reminder.title),
          _DetailRow(label: l10n.labelContent, value: reminder.body),
          _DetailRow(
            label: l10n.labelType,
            value: reminder.type == 'flash' ? l10n.typeFlash : l10n.typeNotification,
          ),
          _DetailRow(
            label: l10n.labelStatus,
            value: reminder.isExpired ? l10n.statusExpired : l10n.statusInProgress,
          ),
          _DetailRow(
            label: l10n.labelScheduledTime,
            value: _formatDateTime(reminder.scheduledTime),
          ),
          if (reminder.repeatRule != null)
            _DetailRow(
              label: l10n.labelRepeat,
              value: reminder.repeatRule.toString(),
            ),
          if (reminder.templateId != null)
            _DetailRow(label: l10n.labelTemplate, value: reminder.templateId!),
        ],
      ),
    );
  }

  String _formatWeekday(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.weekdayMon;
      case DateTime.tuesday:
        return l10n.weekdayTue;
      case DateTime.wednesday:
        return l10n.weekdayWed;
      case DateTime.thursday:
        return l10n.weekdayThu;
      case DateTime.friday:
        return l10n.weekdayFri;
      case DateTime.saturday:
        return l10n.weekdaySat;
      case DateTime.sunday:
        return l10n.weekdaySun;
      default:
        return '';
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Stats card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// History item
class _HistoryItem extends StatelessWidget {
  final Reminder reminder;
  final AppLocalizations l10n;

  const _HistoryItem({required this.reminder, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        reminder.type == 'flash' ? Icons.flash_on : Icons.notifications,
        size: 20,
        color: Colors.grey[500],
      ),
      title: Text(
        reminder.title,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatRelativeTime(reminder.scheduledTime),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(
        Icons.check_circle,
        size: 16,
        color: Colors.green,
      ),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return l10n.xMinutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.xHoursAgo(diff.inHours);
    } else {
      return l10n.xDaysAgo(diff.inDays);
    }
  }
}

/// Detail row
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
