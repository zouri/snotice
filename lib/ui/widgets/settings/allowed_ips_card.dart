import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../main/shell_dimensions.dart';

class AllowedIpsCard extends StatelessWidget {
  const AllowedIpsCard({
    required this.ipController,
    required this.allowedIps,
    required this.onAddIp,
    required this.onRemoveIp,
    required this.onShowInfo,
    super.key,
  });

  final TextEditingController ipController;
  final List<String> allowedIps;
  final VoidCallback onAddIp;
  final ValueChanged<String> onRemoveIp;
  final VoidCallback onShowInfo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final visibleIps = <String>[];
    final seen = <String>{};
    for (final value in allowedIps) {
      final ip = value.trim();
      if (ip.isEmpty || !seen.add(ip)) {
        continue;
      }
      visibleIps.add(ip);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.allowedIPs,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: ShellDimensions.cardTitleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  onPressed: onShowInfo,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: ipController,
                        decoration: InputDecoration(
                          labelText: l10n.addIPAddress,
                          border: const OutlineInputBorder(),
                          hintText: l10n.ipHint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: ShellDimensions.inputVerticalPadding,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: onAddIp,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          l10n.add,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: ShellDimensions.buttonTextSize,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            ShellDimensions.buttonHeight,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ipController,
                        decoration: InputDecoration(
                          labelText: l10n.addIPAddress,
                          border: const OutlineInputBorder(),
                          hintText: l10n.ipHint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: ShellDimensions.inputVerticalPadding,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onAddIp,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        l10n.add,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: ShellDimensions.buttonTextSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          ShellDimensions.buttonHeight,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            if (visibleIps.isEmpty)
              Text(
                l10n.noIPsAdded,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: ShellDimensions.bodySmallSize,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visibleIps.map((ip) {
                  return InputChip(
                    label: Text(
                      ip,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: ShellDimensions.codeSize,
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    onDeleted: () => onRemoveIp(ip),
                    backgroundColor: colorScheme.secondaryContainer,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    deleteIconColor: colorScheme.onSecondaryContainer,
                    deleteIcon: const Icon(Icons.close, size: 16),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
