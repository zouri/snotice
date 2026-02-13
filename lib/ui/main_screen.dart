import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/server_provider.dart';
import 'settings_screen.dart';
import 'widgets/main/reminder_create_tab.dart';
import 'widgets/main/reminder_history_tab.dart';
import 'widgets/main/reminders_tab.dart';
import 'widgets/main/server_status_indicator.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _createReminder() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isServerRunning = context.select<ServerProvider, bool>(
      (provider) => provider.isRunning,
    );
    final port = context.select<ConfigProvider, int>(
      (provider) => provider.config.port,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('SNotice'),
        centerTitle: true,
        actions: [
          ServerStatusIndicator(
            isServerRunning: isServerRunning,
            port: port,
            onTap: _openSettings,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          ReminderCreateTab(
            formKey: _formKey,
            titleController: _titleController,
            bodyController: _bodyController,
            selectedMinutes: _selectedMinutes,
            reminderType: _reminderType,
            flashColor: _flashColor,
            flashDuration: _flashDuration,
            onMinutesChanged: (minutes) {
              setState(() {
                _selectedMinutes = minutes;
              });
            },
            onReminderTypeChanged: (type) {
              setState(() {
                _reminderType = type;
              });
            },
            onFlashColorChanged: (color) {
              setState(() {
                _flashColor = color;
              });
            },
            onFlashDurationChanged: (duration) {
              setState(() {
                _flashDuration = duration;
              });
            },
          ),
          const RemindersTab(),
          const ReminderHistoryTab(),
        ],
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
}
