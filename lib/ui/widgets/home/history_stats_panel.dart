import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/reminder.dart';
import '../../../providers/reminder_provider.dart';
import '../../../services/stats_service.dart';

/// 右栏：历史与统计面板
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
        // 统计概览
        _buildStatsSummary(context),
        const Divider(height: 1),
        // 趋势图表
        _buildTrendsChart(context),
        const Divider(height: 1),
        // 历史记录或详情
        Expanded(
          child: selectedReminder != null
              ? _buildReminderDetail(context, selectedReminder!)
              : _buildHistoryList(context),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
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
                    '今日统计',
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
                      label: '创建',
                      value: stats.totalCreated.toString(),
                      color: Colors.blue,
                    ),
                    _StatCard(
                      label: '完成',
                      value: stats.totalTriggered.toString(),
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: '完成率',
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
    return Container(
      height: 150,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最近7天趋势',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<DailyStats>>(
              future: context.read<StatsService>().getTrends(7),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('暂无数据'),
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
                              _formatWeekday(trend.date.weekday),
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
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        final history = provider.expiredReminders.reversed.take(20).toList();

        return Column(
          children: [
            // 标题
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '历史记录',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: () => provider.clearExpired(),
                      child: const Text('清除'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 列表
            Expanded(
              child: history.isEmpty
                  ? _buildEmptyHistory(context)
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final reminder = history[index];
                        return _HistoryItem(reminder: reminder);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyHistory(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无历史记录',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderDetail(BuildContext context, Reminder reminder) {
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
                '提醒详情',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(label: '标题', value: reminder.title),
          _DetailRow(label: '内容', value: reminder.body),
          _DetailRow(
            label: '类型',
            value: reminder.type == 'flash' ? '闪屏' : '通知',
          ),
          _DetailRow(
            label: '状态',
            value: reminder.isExpired ? '已过期' : '进行中',
          ),
          _DetailRow(
            label: '计划时间',
            value: _formatDateTime(reminder.scheduledTime),
          ),
          if (reminder.repeatRule != null)
            _DetailRow(
              label: '重复',
              value: reminder.repeatRule.toString(),
            ),
          if (reminder.templateId != null)
            _DetailRow(label: '来源模板', value: reminder.templateId!),
        ],
      ),
    );
  }

  String _formatWeekday(int weekday) {
    const names = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${names[weekday - 1]}';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// 统计卡片
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

/// 历史记录项
class _HistoryItem extends StatelessWidget {
  final Reminder reminder;

  const _HistoryItem({required this.reminder});

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
      return '${diff.inMinutes} 分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} 小时前';
    } else {
      return '${diff.inDays} 天前';
    }
  }
}

/// 详情行
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
