import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/reminder_template.dart';
import '../../../providers/template_provider.dart';
import '../../../providers/reminder_provider.dart';

/// 左栏：快捷模板面板
class TemplatePanel extends StatelessWidget {
  const TemplatePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateProvider>(
      builder: (context, templateProvider, _) {
        if (templateProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // 标题
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.apps, size: 20),
                  const SizedBox(width: 8),
                  Text('快捷模板', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            const Divider(height: 1),
            // 模板列表
            Expanded(
              child: templateProvider.templates.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: templateProvider.templates.length,
                      itemBuilder: (context, index) {
                        final template = templateProvider.templates[index];
                        return TemplateCard(
                          template: template,
                          onTap: () => _createFromTemplate(context, template),
                          onFavoriteToggle: () =>
                              _toggleFavorite(context, template),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            // 添加自定义按钮
            _buildAddCustomButton(context),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('暂无模板', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAddCustomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('自定义模板'),
        onPressed: () => _showCreateTemplateDialog(context),
      ),
    );
  }

  void _createFromTemplate(BuildContext context, ReminderTemplate template) {
    final reminderProvider = context.read<ReminderProvider>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    final reminder = reminderProvider.createFromTemplate(template);

    if (messenger == null) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text(
                  '已创建: ${template.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  reminderProvider.removeReminder(reminder.id);
                  messenger.hideCurrentSnackBar();
                },
                child: const Text('撤销'),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _toggleFavorite(BuildContext context, ReminderTemplate template) {
    final provider = context.read<TemplateProvider>();
    provider.toggleFavorite(template.id);
  }

  void _showCreateTemplateDialog(BuildContext context) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    showDialog(
      context: context,
      builder: (context) => _CreateTemplateDialog(
        onSaved: () {
          if (messenger == null) return;
          messenger
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Text('模板已创建'),
                duration: Duration(seconds: 2),
              ),
            );
        },
      ),
    );
  }
}

/// 模板卡片
class TemplateCard extends StatelessWidget {
  final ReminderTemplate template;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    template.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      template.delayDisplay,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // 收藏按钮
              IconButton(
                icon: Icon(
                  template.isFavorite ? Icons.star : Icons.star_border,
                  size: 20,
                  color: template.isFavorite ? Colors.amber : null,
                ),
                onPressed: onFavoriteToggle,
                tooltip: template.isFavorite ? '取消收藏' : '收藏',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 创建自定义模板对话框
class _CreateTemplateDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const _CreateTemplateDialog({required this.onSaved});

  @override
  State<_CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends State<_CreateTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _delayMinutes = 5;
  String _type = 'notification';
  String _icon = '🔔';

  final List<String> _availableIcons = [
    '🔔',
    '⏰',
    '📌',
    '☕',
    '💊',
    '💧',
    '🍅',
    '🧘',
    '👥',
    '🍱',
    '📚',
    '🏃',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建自定义模板'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图标选择
                const Text('图标'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _availableIcons.map((icon) {
                    return ChoiceChip(
                      label: Text(icon, style: const TextStyle(fontSize: 20)),
                      selected: _icon == icon,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _icon = icon);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // 名称
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '模板名称',
                    hintText: '如：喝水提醒',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 延迟时间
                Row(
                  children: [
                    const Text('延迟时间: '),
                    Expanded(
                      child: Slider(
                        value: _delayMinutes.toDouble(),
                        min: 1,
                        max: 480,
                        divisions: 479,
                        label: _formatDelay(_delayMinutes),
                        onChanged: (value) {
                          setState(() => _delayMinutes = value.round());
                        },
                      ),
                    ),
                    Text(_formatDelay(_delayMinutes)),
                  ],
                ),
                const SizedBox(height: 16),
                // 标题
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '提醒标题',
                    hintText: '提醒时显示的标题',
                  ),
                ),
                const SizedBox(height: 16),
                // 内容
                TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: '提醒内容',
                    hintText: '提醒时显示的内容',
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _saveTemplate, child: const Text('保存')),
      ],
    );
  }

  String _formatDelay(int minutes) {
    if (minutes < 60) return '$minutes 分钟';
    if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '$hours 小时 $mins 分钟' : '$hours 小时';
    }
    final days = minutes ~/ 1440;
    return '$days 天';
  }

  void _saveTemplate() {
    if (!_formKey.currentState!.validate()) return;

    final template = ReminderTemplate(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      icon: _icon,
      delayMinutes: _delayMinutes,
      defaultTitle: _titleController.text,
      defaultBody: _bodyController.text,
      type: _type,
      isBuiltIn: false,
      sortOrder: 1000, // 自定义模板排在后面
    );

    context.read<TemplateProvider>().addCustom(template);
    Navigator.pop(context);
    widget.onSaved();
  }
}
