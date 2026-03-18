import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../main/shell_dimensions.dart';

class AutoLaunchSettingsCard extends StatelessWidget {
  const AutoLaunchSettingsCard({
    required this.autoLaunchOnLogin,
    required this.startupSupported,
    required this.onAutoLaunchOnLoginChanged,
    super.key,
  });

  final bool autoLaunchOnLogin;
  final bool startupSupported;
  final ValueChanged<bool> onAutoLaunchOnLoginChanged;

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
                l10n.autoLaunchOnLogin,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: ShellDimensions.bodySize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch(
              value: autoLaunchOnLogin,
              onChanged: startupSupported ? onAutoLaunchOnLoginChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
