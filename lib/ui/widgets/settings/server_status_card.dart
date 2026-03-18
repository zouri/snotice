import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isRunning)
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, ShellDimensions.buttonHeight),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onStart,
                child: Text(
                  l10n.trayStartService,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: ShellDimensions.buttonTextSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (error != null) ...[
              const SizedBox(height: 6),
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
