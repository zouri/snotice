import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/server_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../services/upcoming_window_service.dart';
import '../../models/reminder.dart';
import '../widgets/home/template_panel.dart';
import '../widgets/home/active_reminders_panel.dart';
import '../widgets/home/history_stats_panel.dart';
import '../settings_screen.dart';

/// 新的三栏布局主屏幕
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showRightPanel = true;
  Reminder? _selectedReminder;

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWideScreen = width > 1200;
    final isMediumScreen = width > 800 && width <= 1200;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<ServerProvider>(
        builder: (context, serverProvider, _) {
          return Column(
            children: [
              if (serverProvider.lastError != null)
                _ServerErrorBanner(
                  message: serverProvider.lastError!,
                  onClose: serverProvider.clearLastError,
                ),
              Expanded(child: _buildBody(isWideScreen, isMediumScreen)),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.notifications_active),
          const SizedBox(width: 8),
          const Text('SNotice'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_in_picture_alt),
          tooltip: '切换独立悬浮窗',
          onPressed: () async {
            final success = await context
                .read<UpcomingWindowService>()
                .toggleWindow();
            if (!success && context.mounted) {
              _showSnackBar('悬浮窗操作失败，请重试或重启应用');
            }
          },
        ),
        // 服务器状态指示器
        Consumer<ServerProvider>(
          builder: (context, serverProvider, _) {
            return _ServerStatusIndicator(
              isRunning: serverProvider.isRunning,
              onTap: () => _showQuickSettings(context),
            );
          },
        ),
        // 右侧面板切换按钮（中等屏幕时显示）
        if (MediaQuery.of(context).size.width > 800 &&
            MediaQuery.of(context).size.width <= 1200)
          IconButton(
            icon: Icon(
              _showRightPanel ? Icons.visibility_off : Icons.visibility,
            ),
            tooltip: _showRightPanel ? '隐藏详情面板' : '显示详情面板',
            onPressed: () {
              setState(() {
                _showRightPanel = !_showRightPanel;
              });
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(bool isWideScreen, bool isMediumScreen) {
    if (isWideScreen) {
      // 宽屏幕：三栏布局
      return _buildThreeColumnLayout();
    } else if (isMediumScreen) {
      // 中等屏幕：两栏布局（左栏+中栏，右栏可切换）
      return _buildTwoColumnLayout();
    } else {
      // 窄屏幕：单栏布局
      return _buildSingleColumnLayout();
    }
  }

  /// 三栏布局
  Widget _buildThreeColumnLayout() {
    return Row(
      children: [
        // 左栏：快捷模板
        const SizedBox(width: 250, child: TemplatePanel()),
        const VerticalDivider(width: 1),
        // 中栏：活动提醒
        Expanded(
          child: ActiveRemindersPanel(
            onReminderSelected: (reminder) {
              setState(() {
                _selectedReminder = reminder;
              });
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // 右栏：历史与统计
        SizedBox(
          width: 300,
          child: HistoryStatsPanel(selectedReminder: _selectedReminder),
        ),
      ],
    );
  }

  /// 两栏布局
  Widget _buildTwoColumnLayout() {
    return Row(
      children: [
        // 左栏：快捷模板
        const SizedBox(width: 220, child: TemplatePanel()),
        const VerticalDivider(width: 1),
        // 中栏：活动提醒
        Expanded(
          child: ActiveRemindersPanel(
            onReminderSelected: (reminder) {
              setState(() {
                _selectedReminder = reminder;
              });
              // 中等屏幕时，显示底部详情面板
              _showReminderDetailSheet(reminder);
            },
          ),
        ),
      ],
    );
  }

  /// 单栏布局
  Widget _buildSingleColumnLayout() {
    return ActiveRemindersPanel(
      showQuickTemplates: true, // 在顶部显示快速模板
      onReminderSelected: (reminder) {
        _showReminderDetailSheet(reminder);
      },
    );
  }

  void _showQuickSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _showReminderDetailSheet(Reminder reminder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reminder.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: _ReminderDetailContent(
                      reminder: reminder,
                      onSnoozed: () => _showSnackBar('已延后 5 分钟'),
                      onCancelled: () => _showSnackBar('已取消提醒'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 服务器状态指示器
class _ServerStatusIndicator extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const _ServerStatusIndicator({required this.isRunning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRunning ? Colors.green : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (isRunning ? Colors.green : Colors.red).withValues(
                      alpha: 0.5,
                    ),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isRunning ? '运行中' : '已停止',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _ServerErrorBanner({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MaterialBanner(
      leading: Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
      backgroundColor: colorScheme.errorContainer,
      content: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: Text(
            '关闭',
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
        ),
      ],
    );
  }
}

/// 提醒详情内容
class _ReminderDetailContent extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onSnoozed;
  final VoidCallback onCancelled;

  const _ReminderDetailContent({
    required this.reminder,
    required this.onSnoozed,
    required this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(context, '标题', reminder.title),
        _buildInfoRow(context, '内容', reminder.body),
        _buildInfoRow(context, '类型', reminder.type == 'flash' ? '闪屏' : '通知'),
        _buildInfoRow(context, '计划时间', _formatDateTime(reminder.scheduledTime)),
        _buildInfoRow(context, '创建时间', _formatDateTime(reminder.createdAt)),
        if (reminder.repeatRule != null)
          _buildInfoRow(context, '重复', reminder.repeatRule.toString()),
        if (reminder.templateId != null)
          _buildInfoRow(context, '来源模板', reminder.templateId!),
        const SizedBox(height: 16),
        Consumer<ReminderProvider>(
          builder: (context, provider, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.snooze),
                  label: const Text('贪睡 5 分钟'),
                  onPressed: () {
                    provider.snooze(reminder.id, const Duration(minutes: 5));
                    Navigator.pop(context);
                    onSnoozed();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('取消提醒'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    provider.removeReminder(reminder.id);
                    Navigator.pop(context);
                    onCancelled();
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
