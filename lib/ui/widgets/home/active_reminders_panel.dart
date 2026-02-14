import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/reminder.dart';
import '../../../providers/reminder_provider.dart';
import '../../../providers/template_provider.dart';
import '../../../models/repeat_rule.dart';

/// 中栏：活动提醒面板
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
            // 标题栏
            _buildHeader(context, provider),
            const Divider(height: 1),
            // 快速模板（仅窄屏幕显示）
            if (showQuickTemplates) _buildQuickTemplates(context),
            // 快速创建入口
            _buildQuickCreate(context, provider),
            const Divider(height: 1),
            // 提醒列表
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
    final activeCount = provider.activeReminders.length;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.pending_actions, size: 20),
          const SizedBox(width: 8),
          Text('活动提醒', style: Theme.of(context).textTheme.titleMedium),
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
                              content: Text('已创建: ${template.name}'),
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
              '快速创建提醒',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无活动提醒',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text('点击上方快速创建或使用左侧模板', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context, ReminderProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: provider.activeReminders.length,
      itemBuilder: (context, index) {
        // 按剩余时间排序
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
              const SnackBar(
                content: Text('提醒已创建'),
                duration: Duration(seconds: 2),
              ),
            );
        },
      ),
    );
  }
}

/// 提醒卡片
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
    final isUrgent = widget.reminder.timeUntilReminder.inMinutes < 5;
    final isRepeating = widget.reminder.isRepeating;

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
                  // 图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.reminder.type == 'flash'
                          ? Colors.orange.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.reminder.type == 'flash'
                          ? Icons.flash_on
                          : Icons.notifications,
                      color: widget.reminder.type == 'flash'
                          ? Colors.orange
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 信息
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
                                color: Colors.grey[500],
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.reminder.body,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 倒计时
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isUrgent ? Colors.red : Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.reminder.timeRemaining,
                    style: TextStyle(
                      color: isUrgent ? Colors.red : Colors.grey[600],
                      fontWeight: isUrgent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  // 操作按钮
                  TextButton.icon(
                    icon: const Icon(Icons.snooze, size: 16),
                    label: const Text('贪睡'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: widget.onSnooze,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('取消'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: widget.onCancel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 快速创建对话框
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
  static const Map<int, String> _weekdayLabels = <int, String>{
    DateTime.monday: '一',
    DateTime.tuesday: '二',
    DateTime.wednesday: '三',
    DateTime.thursday: '四',
    DateTime.friday: '五',
    DateTime.saturday: '六',
    DateTime.sunday: '日',
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
    return AlertDialog(
      title: const Text('快速创建提醒'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScheduleModeSelector(),
              const SizedBox(height: 16),
              if (_scheduleMode == 'delay') _buildDelaySelector(),
              if (_scheduleMode == 'time') _buildTimeSelector(context),
              const SizedBox(height: 16),
              // 标题
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '提醒标题',
                ),
              ),
              const SizedBox(height: 16),
              // 内容
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: '内容',
                  hintText: '提醒内容（可选）',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // 类型
              Row(
                children: [
                  const Text('类型: '),
                  Radio<String>(
                    value: 'notification',
                    groupValue: _type,
                    onChanged: (value) {
                      setState(() => _type = value!);
                    },
                  ),
                  const Text('通知'),
                  Radio<String>(
                    value: 'flash',
                    groupValue: _type,
                    onChanged: (value) {
                      setState(() => _type = value!);
                    },
                  ),
                  const Text('闪屏'),
                ],
              ),
              if (_scheduleMode == 'delay') ...[
                const SizedBox(height: 16),
                // 重复选项（计时模式）
                DropdownButtonFormField<String>(
                  initialValue: _repeatRule?.frequency ?? 'none',
                  decoration: const InputDecoration(labelText: '重复'),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('不重复')),
                    DropdownMenuItem(value: 'daily', child: Text('每天')),
                    DropdownMenuItem(value: 'weekly', child: Text('每周')),
                    DropdownMenuItem(value: 'monthly', child: Text('每月')),
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
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _createReminder, child: const Text('创建')),
      ],
    );
  }

  Widget _buildScheduleModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('提醒方式'),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'delay',
              icon: Icon(Icons.timer_outlined),
              label: Text('计时提醒'),
            ),
            ButtonSegment<String>(
              value: 'time',
              icon: Icon(Icons.schedule),
              label: Text('时间提醒'),
            ),
          ],
          selected: <String>{_scheduleMode},
          onSelectionChanged: (selection) {
            setState(() {
              _scheduleMode = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDelaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('快速选择时间'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickDelays.map((minutes) {
            return ChoiceChip(
              label: Text(_formatDelay(minutes)),
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

  Widget _buildTimeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('提醒时间'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pickTime(context),
          icon: const Icon(Icons.access_time),
          label: Text(_formatTimeOfDay(_selectedTime)),
        ),
        const SizedBox(height: 12),
        const Text('重复星期（留空表示仅一次）'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List<Widget>.generate(7, (index) {
            final weekday = index + 1;
            final selected = _selectedWeekdays.contains(weekday);
            return FilterChip(
              label: Text('周${_weekdayLabels[weekday]!}'),
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
              child: const Text('工作日'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedWeekdays
                    ..clear()
                    ..addAll(List<int>.generate(7, (index) => index + 1));
                });
              },
              child: const Text('每天'),
            ),
            TextButton(
              onPressed: () {
                setState(_selectedWeekdays.clear);
              },
              child: const Text('清空'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDelay(int minutes) {
    if (minutes < 60) return '$minutes 分钟';
    if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '$hours 小时';
    }
    final days = minutes ~/ 1440;
    return '$days 天';
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
    final title = _titleController.text.isNotEmpty
        ? _titleController.text
        : '提醒';

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
