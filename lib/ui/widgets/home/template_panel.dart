import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/reminder_template.dart';
import '../../../providers/template_provider.dart';
import '../../../providers/reminder_provider.dart';

/// Left column: Quick templates panel
class TemplatePanel extends StatelessWidget {
  const TemplatePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<TemplateProvider>(
      builder: (context, templateProvider, _) {
        if (templateProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.apps, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.quickTemplates,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Template list
            Expanded(
              child: templateProvider.templates.isEmpty
                  ? _buildEmptyState(context, l10n)
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
            // Add custom button
            _buildAddCustomButton(context, l10n),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTemplates,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCustomButton(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: Text(l10n.customTemplate),
        onPressed: () => _showCreateTemplateDialog(context),
      ),
    );
  }

  void _createFromTemplate(BuildContext context, ReminderTemplate template) {
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.created(template.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  reminderProvider.removeReminder(reminder.id);
                  messenger.hideCurrentSnackBar();
                },
                child: Text(l10n.undo),
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
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);
    showDialog(
      context: context,
      builder: (context) => _CreateTemplateDialog(
        onSaved: () {
          if (messenger == null) return;
          messenger
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.templateCreated),
                duration: const Duration(seconds: 2),
              ),
            );
        },
      ),
    );
  }
}

/// Template card
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
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
              // Info
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  template.isFavorite ? Icons.star : Icons.star_border,
                  size: 20,
                  color: template.isFavorite ? Colors.amber : null,
                ),
                onPressed: onFavoriteToggle,
                tooltip: template.isFavorite ? l10n.unfavorite : l10n.favorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Create custom template dialog
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
  String _flashColor = '#00D1FF';
  int _flashDuration = 700;
  String _flashEffect = 'edge';
  static const List<String> _flashEffects = [
    'edge',
    'edge_pulse',
    'edge_dual',
    'edge_dash',
    'edge_corner',
    'edge_rainbow',
  ];
  static const Map<String, String> _flashEffectLabels = {
    'edge': 'Edge Sweep',
    'edge_pulse': 'Edge Pulse',
    'edge_dual': 'Edge Dual',
    'edge_dash': 'Edge Dash',
    'edge_corner': 'Edge Corner',
    'edge_rainbow': 'Edge Rainbow',
  };

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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      constraints: const BoxConstraints(maxWidth: 520),
      title: Text(l10n.createCustomTemplate),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon selection
                Text(l10n.icon),
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
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.templateName,
                    hintText: l10n.templateNameHint,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.templateNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Delay time
                Row(
                  children: [
                    Text(l10n.delayTime),
                    Expanded(
                      child: Slider(
                        value: _delayMinutes.toDouble(),
                        min: 1,
                        max: 480,
                        divisions: 479,
                        label: _formatDelay(l10n, _delayMinutes),
                        onChanged: (value) {
                          setState(() => _delayMinutes = value.round());
                        },
                      ),
                    ),
                    Text(_formatDelay(l10n, _delayMinutes)),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.reminderTitle,
                    hintText: l10n.reminderTitleHint,
                  ),
                ),
                const SizedBox(height: 16),
                // Content
                TextFormField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: l10n.reminderContent,
                    hintText: l10n.reminderContentHint,
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
                if (_type == 'flash') ...[
                  const SizedBox(height: 12),
                  Text(l10n.flashSettings),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFlashColorButton(context, Colors.red, '#FF0000'),
                      _buildFlashColorButton(context, Colors.yellow, '#FFFF00'),
                      _buildFlashColorButton(context, Colors.blue, '#0000FF'),
                      _buildFlashColorButton(context, Colors.white, '#FFFFFF'),
                      _buildFlashColorButton(context, Colors.grey, '#808080'),
                      _buildFlashColorButton(context, Colors.orange, '#FFA500'),
                      _buildFlashColorButton(
                        context,
                        const Color(0xFF00D1FF),
                        '#00D1FF',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _flashEffects.contains(_flashEffect)
                        ? _flashEffect
                        : _flashEffects.first,
                    decoration: const InputDecoration(labelText: 'Animation'),
                    items: _flashEffects
                        .map(
                          (effect) => DropdownMenuItem(
                            value: effect,
                            child: Text(_flashEffectLabels[effect] ?? effect),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _flashEffect = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(l10n.duration(_flashDuration)),
                      Expanded(
                        child: Slider(
                          value: _flashDuration.toDouble(),
                          min: 100,
                          max: 2500,
                          divisions: 24,
                          label: l10n.duration(_flashDuration),
                          onChanged: (value) {
                            setState(() => _flashDuration = value.round());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(onPressed: _saveTemplate, child: Text(l10n.save)),
      ],
    );
  }

  String _formatDelay(AppLocalizations l10n, int minutes) {
    if (minutes < 60) return l10n.minutesFormat(minutes);
    if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0
          ? l10n.hoursMinutesFormat(hours, mins)
          : l10n.hoursFormat(hours);
    }
    final days = minutes ~/ 1440;
    return l10n.daysFormat(days);
  }

  Widget _buildFlashColorButton(BuildContext context, Color color, String hex) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _flashColor == hex;
    final isLightColor = color.computeLuminance() > 0.6;

    return InkWell(
      onTap: () => setState(() => _flashColor = hex),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 16,
                color: isLightColor ? Colors.black : Colors.white,
              )
            : null,
      ),
    );
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
      flashColor: _type == 'flash' ? _flashColor : null,
      flashDuration: _type == 'flash' ? _flashDuration : null,
      flashEffect: _type == 'flash' ? _flashEffect : null,
      isBuiltIn: false,
      sortOrder: 1000, // Custom templates go last
    );

    context.read<TemplateProvider>().addCustom(template);
    Navigator.pop(context);
    widget.onSaved();
  }
}
