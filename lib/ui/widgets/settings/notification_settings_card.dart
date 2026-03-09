import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../main/shell_dimensions.dart';

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({
    required this.showNotifications,
    required this.showBarrage,
    required this.onShowNotificationsChanged,
    required this.onShowBarrageChanged,
    required this.barrageColorController,
    required this.barrageDurationController,
    required this.barrageSpeedController,
    required this.barrageFontSizeController,
    required this.barrageRepeatController,
    required this.barrageLane,
    required this.onBarrageLaneChanged,
    super.key,
  });

  final bool showNotifications;
  final bool showBarrage;
  final ValueChanged<bool> onShowNotificationsChanged;
  final ValueChanged<bool> onShowBarrageChanged;
  final TextEditingController barrageColorController;
  final TextEditingController barrageDurationController;
  final TextEditingController barrageSpeedController;
  final TextEditingController barrageFontSizeController;
  final TextEditingController barrageRepeatController;
  final String barrageLane;
  final ValueChanged<String?> onBarrageLaneChanged;

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
              l10n.notificationSettings,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: ShellDimensions.cardTitleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.showNotifications,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: ShellDimensions.bodySize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l10n.showNotificationsDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: ShellDimensions.metaSize,
                ),
              ),
              value: showNotifications,
              onChanged: onShowNotificationsChanged,
            ),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.showBarrage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: ShellDimensions.bodySize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l10n.showBarrageDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: ShellDimensions.metaSize,
                ),
              ),
              value: showBarrage,
              onChanged: onShowBarrageChanged,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.barrageDefaultsTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: ShellDimensions.bodySize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 520;
                final children = <Widget>[
                  _TextField(
                    controller: barrageColorController,
                    label: l10n.barrageColorLabel,
                  ),
                  _TextField(
                    controller: barrageDurationController,
                    label: l10n.barrageDurationLabel,
                    keyboardType: TextInputType.number,
                  ),
                  _TextField(
                    controller: barrageSpeedController,
                    label: l10n.barrageSpeedLabel,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  _TextField(
                    controller: barrageFontSizeController,
                    label: l10n.barrageFontSizeLabel,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  _TextField(
                    controller: barrageRepeatController,
                    label: l10n.barrageRepeatLabel,
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: barrageLane,
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: l10n.barrageLaneLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'top',
                        child: Text(l10n.barrageLaneTop),
                      ),
                      DropdownMenuItem(
                        value: 'middle',
                        child: Text(l10n.barrageLaneMiddle),
                      ),
                      DropdownMenuItem(
                        value: 'bottom',
                        child: Text(l10n.barrageLaneBottom),
                      ),
                    ],
                    onChanged: onBarrageLaneChanged,
                  ),
                ];

                if (!wide) {
                  return Column(
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        children[i],
                        if (i != children.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  );
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: children
                      .map(
                        (child) => SizedBox(
                          width: (constraints.maxWidth - 8) / 2,
                          child: child,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
