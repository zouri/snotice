import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../main/shell_dimensions.dart';

class ServerStatusCard extends StatelessWidget {
  const ServerStatusCard({
    required this.isRunning,
    required this.port,
    required this.error,
    required this.onToggle,
    super.key,
  });

  final bool isRunning;
  final int port;
  final String? error;
  final Future<void> Function() onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = isRunning ? colorScheme.tertiary : colorScheme.error;

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
                  isRunning ? l10n.statusRunning : l10n.statusStopped,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: ShellDimensions.bodySize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, ShellDimensions.buttonHeight),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: onToggle,
                  child: Text(
                    isRunning ? l10n.trayStopService : l10n.trayStartService,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: ShellDimensions.buttonTextSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'HTTP Port: $port',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ShellDimensions.bodySmallSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                error!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
