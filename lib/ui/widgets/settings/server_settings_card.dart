import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../main/shell_dimensions.dart';

class ServerSettingsCard extends StatelessWidget {
  const ServerSettingsCard({
    required this.portController,
    required this.autoLaunchOnLogin,
    required this.startupSupported,
    required this.onAutoLaunchOnLoginChanged,
    super.key,
  });

  final TextEditingController portController;
  final bool autoLaunchOnLogin;
  final bool startupSupported;
  final ValueChanged<bool> onAutoLaunchOnLoginChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.serverSettings,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: ShellDimensions.cardTitleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: portController,
              decoration: InputDecoration(
                labelText: l10n.serverPort,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: ShellDimensions.inputVerticalPadding,
                ),
                suffixIcon: const Icon(Icons.settings_ethernet, size: 20),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ShellDimensions.bodySize,
                fontWeight: FontWeight.w600,
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
            const SizedBox(height: 8),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.autoLaunchOnLogin,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: ShellDimensions.bodySize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l10n.autoLaunchOnLoginDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: ShellDimensions.metaSize,
                ),
              ),
              value: autoLaunchOnLogin,
              onChanged: startupSupported ? onAutoLaunchOnLoginChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
