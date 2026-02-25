import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/reminder.dart';
import '../../../providers/reminder_provider.dart';
import '../../../providers/template_provider.dart';
import '../../../models/repeat_rule.dart';

/// Middle column: Active reminders panel
class ActiveRemindersPanel extends StatelessWidget {
  final bool showQuickTemplates;
  final void Function(Reminder)? onReminderSelected;

  const ActiveRemindersPanel({
    super.key,
    this.showQuickTemplates = false,
    this.onReminderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Header
            _buildHeader(context, provider),
            const Divider(height: 1),
            // Quick templates (only on narrow screens)
            if (showQuickTemplates) _buildQuickTemplates(context),
            // Quick create entry
            _buildQuickCreate(context, provider),
            const Divider(height: 1),
            // Reminder list
            Expanded(
              child: provider.activeReminders.isEmpty
                  ? _buildEmptyState(context)
                  : _buildRemindersList(context, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ReminderProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final activeCount = provider.activeReminders.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.pending_actions, size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.activeReminders,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          if (activeCount > 0)
            Chip(
              label: Text('$activeCount'),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickTemplates(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, _) {
        return Consumer<TemplateProvider>(
          builder: (context, templateProvider, _) {
            final l10n = AppLocalizations.of(context)!;
            final favorites = templateProvider.favoriteTemplates;
            if (favorites.isEmpty) return const SizedBox.shrink();

            return Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final template = favorites[index];
                  return SizedBox(
                    width: 100,
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          reminderProvider.createFromTemplate(template);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.created(template.name)),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                template.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                template.name,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickCreate(BuildContext context, ReminderProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showQuickCreateDialog(context, provider),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.quickCreateReminder,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_off, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            l10n.noActiveReminders,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noActiveRemindersDesc,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context, ReminderProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: provider.activeReminders.length,
      itemBuilder: (context, index) {
        // Sort by remaining time
        final sortedReminders = provider.activeReminders.toList()
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        final sortedReminder = sortedReminders[index];
        return ReminderCard(
          reminder: sortedReminder,
          onCancel: () => provider.removeReminder(sortedReminder.id),
          onSnooze: () =>
              provider.snooze(sortedReminder.id, const Duration(minutes: 5)),
          onTap: () => onReminderSelected?.call(sortedReminder),
        );
      },
    );
  }

  void _showQuickCreateDialog(BuildContext context, ReminderProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);
    showDialog(
      context: context,
      builder: (context) => _QuickCreateDialog(
        provider: provider,
        onCreated: () {
          if (messenger == null) return;
          messenger
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.reminderCreated),
                duration: const Duration(seconds: 2),
              ),
            );
        },
      ),
    );
  }
}

/// Reminder card
class ReminderCard extends StatefulWidget {
  final Reminder reminder;
  final VoidCallback onCancel;
  final VoidCallback onSnooze;
  final VoidCallback? onTap;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onCancel,
    required this.onSnooze,
    this.onTap,
  });

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isUrgent = widget.reminder.timeUntilReminder.inMinutes < 5;
    final isRepeating = widget.reminder.isRepeating;
    final timeColor = isUrgent
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.reminder.type == 'flash'
                          ? colorScheme.tertiaryContainer
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.reminder.type == 'flash'
                          ? Icons.flash_on
                          : Icons.notifications,
                      color: widget.reminder.type == 'flash'
                          ? colorScheme.tertiary
                          : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.reminder.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isRepeating)
                              Icon(
                                Icons.repeat,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.reminder.body,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 460;
                  final timeInfo = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 16, color: timeColor),
                      const SizedBox(width: 4),
                      Text(
                        widget.reminder.timeRemaining,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: timeColor,
                          fontWeight: isUrgent
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  );

                  final actions = Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.snooze, size: 16),
                        label: Text(l10n.snooze),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: widget.onSnooze,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.cancel, size: 16),
                        label: Text(l10n.cancel),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: widget.onCancel,
                      ),
                    ],
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [timeInfo, const SizedBox(height: 8), actions],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: timeInfo),
                      actions,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick create dialog
class _QuickCreateDialog extends StatefulWidget {
  final ReminderProvider provider;
  final VoidCallback onCreated;

  const _QuickCreateDialog({required this.provider, required this.onCreated});

  @override
  State<_QuickCreateDialog> createState() => _QuickCreateDialogState();
}

class _QuickCreateDialogState extends State<_QuickCreateDialog> {
  static const Set<int> _workdays = <int>{
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  };

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _delayMinutes = 5;
  String _scheduleMode = 'delay';
  String _type = 'notification';
  RepeatRule? _repeatRule;
  late TimeOfDay _selectedTime;
  final Set<int> _selectedWeekdays = Set<int>.from(_workdays);

  final List<int> _quickDelays = [1, 5, 10, 15, 30, 60, 120, 240];

  @override
  void initState() {
    super.initState();
    _selectedTime = const TimeOfDay(hour: 11, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      constraints: const BoxConstraints(maxWidth: 520),
      title: Text(l10n.quickCreateReminder),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScheduleModeSelector(l10n),
              const SizedBox(height: 16),
              if (_scheduleMode == 'delay') _buildDelaySelector(l10n),
              if (_scheduleMode == 'time') _buildTimeSelector(context, l10n),
              const SizedBox(height: 16),
              // Title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.reminderTitle,
                  hintText: l10n.reminderTitle,
                ),
              ),
              const SizedBox(height: 16),
              // Content
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: l10n.reminderContent,
                  hintText: l10n.reminderContentOptional,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Type
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(l10n.typeLabel),
                  ChoiceChip(
                    label: Text(l10n.typeNotification),
                    selected: _type == 'notification',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _type = 'notification');
                      }
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.typeFlash),
                    selected: _type == 'flash',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _type = 'flash');
                      }
                    },
                  ),
                ],
              ),
              if (_scheduleMode == 'delay') ...[
                const SizedBox(height: 16),
                // Repeat option (delay mode)
                DropdownButtonFormField<String>(
                  initialValue: _repeatRule?.frequency ?? 'none',
                  decoration: InputDecoration(labelText: l10n.repeatLabel),
                  items: [
                    DropdownMenuItem(value: 'none', child: Text(l10n.noRepeat)),
                    DropdownMenuItem(value: 'daily', child: Text(l10n.daily)),
                    DropdownMenuItem(value: 'weekly', child: Text(l10n.weekly)),
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text(l10n.monthly),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == 'none') {
                        _repeatRule = null;
                      } else {
                        _repeatRule = RepeatRule(frequency: value!);
                      }
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(onPressed: _createReminder, child: Text(l10n.create)),
      ],
    );
  }

  Widget _buildScheduleModeSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reminderMode),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              avatar: const Icon(Icons.timer_outlined, size: 16),
              label: Text(l10n.countdownReminder),
              selected: _scheduleMode == 'delay',
              onSelected: (selected) {
                if (selected) {
                  setState(() => _scheduleMode = 'delay');
                }
              },
            ),
            ChoiceChip(
              avatar: const Icon(Icons.schedule, size: 16),
              label: Text(l10n.timeReminder),
              selected: _scheduleMode == 'time',
              onSelected: (selected) {
                if (selected) {
                  setState(() => _scheduleMode = 'time');
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDelaySelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickSelectTime),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickDelays.map((minutes) {
            return ChoiceChip(
              label: Text(_formatDelay(l10n, minutes)),
              selected: _delayMinutes == minutes,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _delayMinutes = minutes);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reminderTime),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pickTime(context),
          icon: const Icon(Icons.access_time),
          label: Text(_formatTimeOfDay(_selectedTime)),
        ),
        const SizedBox(height: 12),
        Text(l10n.repeatWeekdays),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List<Widget>.generate(7, (index) {
            final weekday = index + 1;
            final selected = _selectedWeekdays.contains(weekday);
            return FilterChip(
              label: Text(_getWeekdayLabel(l10n, weekday)),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _selectedWeekdays.add(weekday);
                  } else {
                    _selectedWeekdays.remove(weekday);
                  }
                });
              },
            );
          }),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedWeekdays
                    ..clear()
                    ..addAll(_workdays);
                });
              },
              child: Text(l10n.workdays),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedWeekdays
                    ..clear()
                    ..addAll(List<int>.generate(7, (index) => index + 1));
                });
              },
              child: Text(l10n.everyday),
            ),
            TextButton(
              onPressed: () {
                setState(_selectedWeekdays.clear);
              },
              child: Text(l10n.clear),
            ),
          ],
        ),
      ],
    );
  }

  String _getWeekdayLabel(AppLocalizations l10n, int weekday) {
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

  String _formatDelay(AppLocalizations l10n, int minutes) {
    if (minutes < 60) return l10n.minutesFormat(minutes);
    if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return l10n.hoursFormat(hours);
    }
    final days = minutes ~/ 1440;
    return l10n.daysFormat(days);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (selected == null) return;
    setState(() {
      _selectedTime = selected;
    });
  }

  DateTime _nextTimeReminderAt() {
    final now = DateTime.now();
    final hasWeekdayFilter = _selectedWeekdays.isNotEmpty;

    if (!hasWeekdayFilter) {
      final today = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      if (today.isAfter(now)) {
        return today;
      }
      return today.add(const Duration(days: 1));
    }

    final sorted = _selectedWeekdays.toList()..sort();
    for (int i = 0; i < 14; i++) {
      final date = now.add(Duration(days: i));
      final candidate = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      if (!sorted.contains(candidate.weekday)) {
        continue;
      }
      if (candidate.isAfter(now)) {
        return candidate;
      }
    }

    final fallback = now.add(const Duration(days: 1));
    return DateTime(
      fallback.year,
      fallback.month,
      fallback.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  RepeatRule? _buildTimeRepeatRule() {
    if (_selectedWeekdays.isEmpty) {
      return null;
    }
    final weekdays = _selectedWeekdays.toList()..sort();
    return RepeatRule(frequency: 'weekly', interval: 1, weekdays: weekdays);
  }

  void _createReminder() {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.isNotEmpty
        ? _titleController.text
        : l10n.reminder;

    if (_scheduleMode == 'time') {
      widget.provider.addReminderAt(
        title: title,
        body: _bodyController.text,
        scheduledTime: _nextTimeReminderAt(),
        type: _type,
        repeatRule: _buildTimeRepeatRule(),
      );
    } else {
      widget.provider.addReminder(
        title: title,
        body: _bodyController.text,
        delay: Duration(minutes: _delayMinutes),
        type: _type,
        repeatRule: _repeatRule,
      );
    }

    Navigator.pop(context);
    widget.onCreated();
  }
}
