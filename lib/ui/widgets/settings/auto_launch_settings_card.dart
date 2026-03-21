import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_text_styles.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.autoLaunchOnLogin,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: ShellDimensions.bodySize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.autoLaunchOnLoginDesc,
                    style: AppTextStyles.bodySm.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
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
