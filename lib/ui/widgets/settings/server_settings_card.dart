import 'package:flutter/material.dart';

class ServerSettingsCard extends StatelessWidget {
  const ServerSettingsCard({
    required this.portController,
    required this.autoStart,
    required this.onAutoStartChanged,
    super.key,
  });

  final TextEditingController portController;
  final bool autoStart;
  final ValueChanged<bool> onAutoStartChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Server Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.settings_ethernet),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a port';
                }
                final port = int.tryParse(value);
                if (port == null || port < 1 || port > 65535) {
                  return 'Please enter a valid port (1-65535)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto Start'),
              subtitle: const Text('Start server automatically on app launch'),
              value: autoStart,
              onChanged: onAutoStartChanged,
            ),
          ],
        ),
      ),
    );
  }
}
