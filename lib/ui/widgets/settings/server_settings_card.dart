import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_text_styles.dart';
import '../main/shell_dimensions.dart';

class ServerSettingsCard extends StatelessWidget {
  const ServerSettingsCard({required this.portController, super.key});

  final TextEditingController portController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.serverPort,
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: ShellDimensions.bodySize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 132,
              child: TextFormField(
                controller: portController,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '8642',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
