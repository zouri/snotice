import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.serverSettings,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: portController,
              decoration: InputDecoration(
                labelText: l10n.serverPort,
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.settings_ethernet),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.serverPortRequired;
                }
                final port = int.tryParse(value);
                if (port == null || port < 1 || port > 65535) {
                  return l10n.serverPortInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.serverAutoStart),
              subtitle: Text(l10n.serverAutoStartDesc),
              value: autoStart,
              onChanged: onAutoStartChanged,
            ),
          ],
        ),
      ),
    );
  }
}
