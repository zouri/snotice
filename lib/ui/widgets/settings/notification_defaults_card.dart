import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/color_value_utils.dart';
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
                _ColorPickerField(
                  controller: flashColorController,
                  label: l10n.flashColorLabel,
                  fallbackColor: const Color(0xFFFF0000),
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
                _ColorPickerField(
                  controller: barrageColorController,
                  label: l10n.barrageColorLabel,
                  fallbackColor: const Color(0xFFFFD84D),
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

class _ColorPickerField extends StatelessWidget {
  const _ColorPickerField({
    required this.controller,
    required this.label,
    required this.fallbackColor,
  });

  final TextEditingController controller;
  final String label;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final selectedColor = parseColorValue(
          value.text,
          fallback: fallbackColor,
        );
        final displayValue = value.text.trim().isEmpty
            ? colorToHex(selectedColor)
            : value.text.trim().toUpperCase();

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
            InkWell(
              borderRadius: BorderRadius.circular(ShellDimensions.radiusMd),
              onTap: () async {
                final selected = await showDialog<String>(
                  context: context,
                  builder: (context) =>
                      _ColorPickerDialog(initialColor: selectedColor),
                );

                if (selected != null) {
                  controller.text = selected;
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        displayValue,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.color_lens_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initialColor});

  final Color initialColor;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  static const List<Color> _presetColors = [
    Color(0xFFFF0000),
    Color(0xFFFF6B00),
    Color(0xFFFFD84D),
    Color(0xFF22C55E),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFFFFFFF),
    Color(0xFF111827),
  ];

  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.color),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 72,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(ShellDimensions.radiusMd),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                alignment: Alignment.center,
                child: Text(
                  colorToHex(_selectedColor),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: _selectedColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presetColors.map((color) {
                  final selected =
                      colorToHex(color) == colorToHex(_selectedColor);
                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: selected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _ColorChannelSlider(
                label: 'R',
                value: _colorChannel(_selectedColor.r),
                activeColor: Colors.red,
                onChanged: (value) {
                  setState(() {
                    _selectedColor = _selectedColor.withRed(value.round());
                  });
                },
              ),
              _ColorChannelSlider(
                label: 'G',
                value: _colorChannel(_selectedColor.g),
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    _selectedColor = _selectedColor.withGreen(value.round());
                  });
                },
              ),
              _ColorChannelSlider(
                label: 'B',
                value: _colorChannel(_selectedColor.b),
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    _selectedColor = _selectedColor.withBlue(value.round());
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(colorToHex(_selectedColor)),
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}

double _colorChannel(double value) {
  return (value * 255).round().clamp(0, 255).toDouble();
}

class _ColorChannelSlider extends StatelessWidget {
  const _ColorChannelSlider({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  final String label;
  final double value;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.16),
            ),
            child: Slider(
              min: 0,
              max: 255,
              divisions: 255,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.round().toString(),
            textAlign: TextAlign.end,
            style: AppTextStyles.bodySm.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
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
