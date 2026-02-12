import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/server_provider.dart';
import '../providers/config_provider.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedMinutes = 5;
  String _reminderType = 'notification';
  String _flashColor = '#FFFFFF';
  int _flashDuration = 500;
  int _selectedTab = 0;

  final List<int> _quickTimes = [1, 5, 10, 30, 60];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _createReminder() {
    if (_formKey.currentState!.validate()) {
      final reminderProvider = context.read<ReminderProvider>();

      final delay = Duration(minutes: _selectedMinutes);

      reminderProvider.addReminder(
        title: _titleController.text,
        body: _bodyController.text,
        delay: delay,
        type: _reminderType,
        flashColor: _reminderType == 'flash' ? _flashColor : null,
        flashDuration: _reminderType == 'flash' ? _flashDuration : null,
      );

      _titleController.clear();
      _bodyController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set for $_selectedMinutes minutes'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _selectedTab = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNotice'),
        centerTitle: true,
        actions: [_buildServerStatusIndicator()],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [_buildCreateTab(), _buildRemindersTab(), _buildHistoryTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_alarm), label: 'Create'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: _createReminder,
              icon: const Icon(Icons.alarm_add),
              label: const Text('Set Reminder'),
            )
          : null,
    );
  }

  Widget _buildServerStatusIndicator() {
    return Consumer<ServerProvider>(
      builder: (context, serverProvider, child) {
        return Consumer<ConfigProvider>(
          builder: (context, configProvider, child) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      serverProvider.isRunning
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      color: serverProvider.isRunning
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ':${configProvider.config.port}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickTimeButtons(),
            const SizedBox(height: 20),
            _buildTimeSlider(),
            const SizedBox(height: 20),
            _buildReminderTypeSelector(),
            const SizedBox(height: 20),
            _buildReminderForm(),
            if (_reminderType == 'flash') ...[
              const SizedBox(height: 20),
              _buildFlashSettings(),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTimeButtons() {
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
                final isSelected = _selectedMinutes == minutes;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMinutes = minutes;
                    });
                  },
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

  Widget _buildTimeSlider() {
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
                  '$_selectedMinutes min',
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
              value: _selectedMinutes.toDouble(),
              min: 1,
              max: 120,
              divisions: 119,
              label: '$_selectedMinutes min',
              onChanged: (value) {
                setState(() {
                  _selectedMinutes = value.toInt();
                });
              },
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
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Notification'),
                    subtitle: const Text('System notification'),
                    value: 'notification',
                    groupValue: _reminderType,
                    onChanged: (value) {
                      setState(() {
                        _reminderType = value!;
                      });
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Flash Screen'),
                    subtitle: const Text('Full screen overlay'),
                    value: 'flash',
                    groupValue: _reminderType,
                    onChanged: (value) {
                      setState(() {
                        _reminderType = value!;
                      });
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
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
              controller: _titleController,
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
              controller: _bodyController,
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
            Text('Duration: ${_flashDuration}ms'),
            Slider(
              value: _flashDuration.toDouble(),
              min: 100,
              max: 2000,
              divisions: 19,
              label: '${_flashDuration}ms',
              onChanged: (value) {
                setState(() {
                  _flashDuration = value.toInt();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color, String hex) {
    return InkWell(
      onTap: () => setState(() => _flashColor = hex),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _flashColor == hex ? Colors.black : Colors.grey,
            width: _flashColor == hex ? 3 : 1,
          ),
        ),
        child: _flashColor == hex
            ? const Icon(Icons.check, color: Colors.black, size: 20)
            : null,
      ),
    );
  }

  Widget _buildRemindersTab() {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        final activeReminders = reminderProvider.activeReminders;

        if (activeReminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.alarm_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No active reminders',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: activeReminders.length,
          itemBuilder: (context, index) {
            final reminder = activeReminders[index];
            return _buildReminderCard(reminder, reminderProvider);
          },
        );
      },
    );
  }

  Widget _buildReminderCard(reminder, ReminderProvider reminderProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reminder.type == 'flash'
              ? Colors.orange.withOpacity(0.1)
              : Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            reminder.type == 'flash' ? Icons.fullscreen : Icons.notifications,
            color: reminder.type == 'flash'
                ? Colors.orange
                : Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.body, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              reminder.timeRemaining,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            reminderProvider.removeReminder(reminder.id);
          },
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        final expiredReminders = reminderProvider.expiredReminders;

        if (expiredReminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No reminder history',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (expiredReminders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: () {
                    reminderProvider.clearExpired();
                  },
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear History'),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: expiredReminders.length,
                itemBuilder: (context, index) {
                  final reminder = expiredReminders[index];
                  return _buildHistoryCard(reminder);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(reminder) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.check_circle, color: Colors.grey[600]),
        ),
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          reminder.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatHistoryTime(reminder.createdAt),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }

  String _formatHistoryTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
