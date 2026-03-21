import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../main/shell_dimensions.dart';

class NotificationDefaultsCard extends StatelessWidget {
  const NotificationDefaultsCard({
    required this.flashColorController,
    required this.flashDurationController,
    required this.flashEdgeWidthController,
    required this.flashEdgeOpacityController,
    required this.flashEdgeRepeatController,
    required this.barrageColorController,
    required this.barrageDurationController,
    required this.barrageSpeedController,
    required this.barrageFontSizeController,
    required this.barrageRepeatController,
    required this.barrageLane,
    required this.onBarrageLaneChanged,
    super.key,
  });

  final TextEditingController flashColorController;
  final TextEditingController flashDurationController;
  final TextEditingController flashEdgeWidthController;
  final TextEditingController flashEdgeOpacityController;
  final TextEditingController flashEdgeRepeatController;
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationDefaultsTitle,
              style: AppTextStyles.cardTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.notificationDefaultsDesc,
              style: AppTextStyles.bodySm.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            _DefaultsSection(
              title: l10n.flashDefaultsTitle,
              backgroundColor: AppColors.warningLight.withValues(alpha: 0.45),
              borderColor: AppColors.warning.withValues(alpha: 0.14),
              children: [
                _FieldInput(
                  controller: flashColorController,
                  label: l10n.flashColorLabel,
                ),
                _FieldInput(
                  controller: flashDurationController,
                  label: l10n.flashDurationLabel,
                  keyboardType: TextInputType.number,
                ),
                _FieldInput(
                  controller: flashEdgeWidthController,
                  label: l10n.flashEdgeWidthLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _FieldInput(
                  controller: flashEdgeOpacityController,
                  label: l10n.flashEdgeOpacityLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _FieldInput(
                  controller: flashEdgeRepeatController,
                  label: l10n.flashEdgeRepeatLabel,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DefaultsSection(
              title: l10n.barrageDefaultsTitle,
              backgroundColor: AppColors.primaryContainer.withValues(
                alpha: 0.45,
              ),
              borderColor: colorScheme.primary.withValues(alpha: 0.14),
              children: [
                _FieldInput(
                  controller: barrageColorController,
                  label: l10n.barrageColorLabel,
                ),
                _FieldInput(
                  controller: barrageDurationController,
                  label: l10n.barrageDurationLabel,
                  keyboardType: TextInputType.number,
                ),
                _FieldInput(
                  controller: barrageSpeedController,
                  label: l10n.barrageSpeedLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _FieldInput(
                  controller: barrageFontSizeController,
                  label: l10n.barrageFontSizeLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _FieldInput(
                  controller: barrageRepeatController,
                  label: l10n.barrageRepeatLabel,
                  keyboardType: TextInputType.number,
                ),
                _LaneSelector(
                  label: l10n.barrageLaneLabel,
                  value: barrageLane,
                  onChanged: onBarrageLaneChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultsSection extends StatelessWidget {
  const _DefaultsSection({
    required this.title,
    required this.backgroundColor,
    required this.borderColor,
    required this.children,
  });

  final String title;
  final Color backgroundColor;
  final Color borderColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ShellDimensions.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 520;
              final fieldWidth = wide
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: children.map((child) {
                  return SizedBox(width: fieldWidth, child: child);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FieldInput extends StatelessWidget {
  const _FieldInput({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _LaneSelector extends StatelessWidget {
  const _LaneSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final options = <(String, String)>[
      ('top', l10n.barrageLaneTop),
      ('middle', l10n.barrageLaneMiddle),
      ('bottom', l10n.barrageLaneBottom),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = value == option.$1;
            return ChoiceChip(
              label: Text(option.$2),
              selected: selected,
              onSelected: (_) => onChanged(option.$1),
              showCheckmark: false,
              selectedColor: colorScheme.primaryContainer,
              backgroundColor: colorScheme.surface,
              side: BorderSide(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
              labelStyle: AppTextStyles.labelMd.copyWith(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
