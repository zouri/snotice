import 'package:flutter/material.dart';

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
            _buildReminderTypeSelector(),
            const SizedBox(height: 20),
            _buildReminderForm(),
            if (reminderType == 'flash') ...[
              const SizedBox(height: 20),
              _buildFlashSettings(),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTimeButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                          ? '${(minutes / 60).toInt()}h'
                          : '${minutes}m',
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Custom Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$selectedMinutes min',
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
              label: '$selectedMinutes min',
              onChanged: (value) => onMinutesChanged(value.toInt()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminder Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      title: const Text('Notification'),
                      subtitle: const Text('System notification'),
                      value: 'notification',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Flash Screen'),
                      subtitle: const Text('Full screen overlay'),
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

  Widget _buildReminderForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a message';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flash Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Color'),
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
            Text('Duration: ${flashDuration}ms'),
            Slider(
              value: flashDuration.toDouble(),
              min: 100,
              max: 2000,
              divisions: 19,
              label: '${flashDuration}ms',
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
