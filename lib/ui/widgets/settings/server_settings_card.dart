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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.serverSettings,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.httpApiParamPortDesc,
                    style: AppTextStyles.bodySm.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: TextFormField(
                controller: portController,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: l10n.serverPort,
                  hintText: '8642',
                  border: const OutlineInputBorder(),
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
