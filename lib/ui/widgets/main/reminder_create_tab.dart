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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickTime,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      minutes >= 60
                          ? l10n.hours(minutes ~/ 60)
                          : l10n.minutes(minutes),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  l10n.minutes(selectedMinutes),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(l10n.notification),
                      subtitle: Text(l10n.notificationDesc),
                      value: 'notification',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(l10n.flashScreen),
                      subtitle: Text(l10n.flashScreenDesc),
                      value: 'flash',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.flashSettings,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(l10n.color),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorButton(Colors.red, '#FF0000'),
                _buildColorButton(Colors.yellow, '#FFFF00'),
                _buildColorButton(Colors.blue, '#0000FF'),
                _buildColorButton(Colors.white, '#FFFFFF'),
                _buildColorButton(Colors.grey, '#808080'),
                _buildColorButton(Colors.orange, '#FFA500'),
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

  Widget _buildColorButton(Color color, String hex) {
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
            color: flashColor == hex ? Colors.black : Colors.grey,
            width: flashColor == hex ? 3 : 1,
          ),
        ),
        child: flashColor == hex
            ? const Icon(Icons.check, color: Colors.black, size: 20)
            : null,
      ),
    );
  }
}
