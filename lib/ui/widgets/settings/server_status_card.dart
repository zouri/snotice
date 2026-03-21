import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../main/shell_dimensions.dart';

class ServerStatusCard extends StatelessWidget {
  const ServerStatusCard({
    required this.isRunning,
    required this.error,
    required this.onStart,
    super.key,
  });

  final bool isRunning;
  final String? error;
  final Future<void> Function() onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = isRunning
        ? AppColors.successFor(Theme.of(context).brightness)
        : AppColors.errorFor(Theme.of(context).brightness);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isRunning
                      ? l10n.trayServiceRunning
                      : l10n.trayServiceNotRunning,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                error!,
                style: AppTextStyles.bodySm.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
            if (!isRunning) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: ShellDimensions.buttonHeight,
                child: FilledButton(
                  onPressed: onStart,
                  child: Text(l10n.trayStartService),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
