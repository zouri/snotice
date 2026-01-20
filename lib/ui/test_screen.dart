import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_request.dart';
import '../providers/config_provider.dart';
import '../services/notification_service.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _priority = 'normal';
  String _category = 'info';
  String _flashColor = '#FFFFFF';
  int _flashDuration = 500;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _sendTestNotification() {
    if (_formKey.currentState!.validate()) {
      final request = NotificationRequest(
        title: _titleController.text,
        body: _bodyController.text,
        priority: _priority,
        category: _category,
        flashColor: _category == 'flash' ? _flashColor : null,
        flashDuration: _category == 'flash' ? _flashDuration : null,
      );

      context.read<NotificationService>().showNotification(request);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _category == 'flash'
                ? 'Flash effect triggered!'
                : 'Test notification sent',
          ),
        ),
      );
    }
  }

  void _usePreset(String title, String body) {
    setState(() {
      _titleController.text = title;
      _bodyController.text = body;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>().config;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Notifications')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Presets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _usePreset(
                              'Hello',
                              'This is a test notification',
                            ),
                            icon: const Icon(Icons.message),
                            label: const Text('Simple'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _usePreset(
                              'Important',
                              'This is an important notification',
                            ),
                            icon: const Icon(Icons.priority_high),
                            label: const Text('Important'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _usePreset(
                              'Alert',
                              'This is an alert notification',
                            ),
                            icon: const Icon(Icons.warning),
                            label: const Text('Alert'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notification Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          labelText: 'Body',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a body';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.priority_high),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Low')),
                          DropdownMenuItem(
                            value: 'normal',
                            child: Text('Normal'),
                          ),
                          DropdownMenuItem(value: 'high', child: Text('High')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _priority = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'info', child: Text('Info')),
                          DropdownMenuItem(
                            value: 'alert',
                            child: Text('Alert'),
                          ),
                          DropdownMenuItem(
                            value: 'success',
                            child: Text('Success'),
                          ),
                          DropdownMenuItem(
                            value: 'warning',
                            child: Text('Warning'),
                          ),
                          DropdownMenuItem(
                            value: 'flash',
                            child: Text('Flash (Screen)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _category = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_category == 'flash') ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Flash Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Duration (ms)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _flashDuration = int.tryParse(value) ?? 500;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: config.showNotifications
                      ? _sendTestNotification
                      : null,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Send Notification',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (!config.showNotifications)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Notifications are disabled in settings',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
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
}
