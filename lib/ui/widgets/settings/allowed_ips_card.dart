import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.allowedIPs,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: onShowInfo,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: onAddIp,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.add),
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onAddIp,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.add),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            if (allowedIps.isEmpty)
              Text(
                l10n.noIPsAdded,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allowedIps.map((ip) {
                  return Chip(
                    label: Text(ip),
                    onDeleted: () => onRemoveIp(ip),
                    deleteIcon: const Icon(Icons.close),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
