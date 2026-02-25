import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ReminderCreateTab extends StatelessWidget {
  const ReminderCreateTab({
    required this.formKey,
    required this.titleController,
    required this.bodyController,
    required this.selectedMinutes,
    required this.reminderType,
    required this.flashColor,
    required this.flashDuration,
    required this.onMinutesChanged,
    required this.onReminderTypeChanged,
    required this.onFlashColorChanged,
    required this.onFlashDurationChanged,
    super.key,
  });

  static const List<int> _quickTimes = [1, 5, 10, 30, 60];

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final int selectedMinutes;
  final String reminderType;
  final String flashColor;
  final int flashDuration;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<String> onReminderTypeChanged;
  final ValueChanged<String> onFlashColorChanged;
  final ValueChanged<int> onFlashDurationChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickTimeButtons(context),
            const SizedBox(height: 20),
            _buildTimeSlider(context),
            const SizedBox(height: 20),
            _buildReminderTypeSelector(context),
            const SizedBox(height: 20),
            _buildReminderForm(context),
            if (reminderType == 'flash') ...[
              const SizedBox(height: 20),
              _buildFlashSettings(context),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTimeButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickTime,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTimes.map((minutes) {
                final isSelected = selectedMinutes == minutes;
                return InkWell(
                  onTap: () => onMinutesChanged(minutes),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      minutes >= 60
                          ? l10n.hours(minutes ~/ 60)
                          : l10n.minutes(minutes),
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlider(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.customTime,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.minutes(selectedMinutes),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: selectedMinutes.toDouble(),
              min: 1,
              max: 120,
              divisions: 119,
              label: l10n.minutes(selectedMinutes),
              onChanged: (value) => onMinutesChanged(value.toInt()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTypeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reminderType,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: reminderType,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                onReminderTypeChanged(value);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 560;

                  final notificationTile = RadioListTile<String>(
                    title: Text(l10n.notification),
                    subtitle: Text(l10n.notificationDesc),
                    value: 'notification',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  );
                  final flashTile = RadioListTile<String>(
                    title: Text(l10n.flashScreen),
                    subtitle: Text(l10n.flashScreenDesc),
                    value: 'flash',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  );

                  if (compact) {
                    return Column(children: [notificationTile, flashTile]);
                  }

                  return Row(
                    children: [
                      Expanded(child: notificationTile),
                      Expanded(child: flashTile),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderForm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: l10n.labelTitle,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.titleRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: bodyController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.message,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.messageRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.flashSettings,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.color,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorButton(context, Colors.red, '#FF0000'),
                _buildColorButton(context, Colors.yellow, '#FFFF00'),
                _buildColorButton(context, Colors.blue, '#0000FF'),
                _buildColorButton(context, Colors.white, '#FFFFFF'),
                _buildColorButton(context, Colors.grey, '#808080'),
                _buildColorButton(context, Colors.orange, '#FFA500'),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.duration(flashDuration)),
            Slider(
              value: flashDuration.toDouble(),
              min: 100,
              max: 2000,
              divisions: 19,
              label: l10n.duration(flashDuration),
              onChanged: (value) => onFlashDurationChanged(value.toInt()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(BuildContext context, Color color, String hex) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = flashColor == hex;
    final isLightColor = color.computeLuminance() > 0.6;

    return InkWell(
      onTap: () => onFlashColorChanged(hex),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 45,
        height: 45,
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
                color: isLightColor ? Colors.black : Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }
}
