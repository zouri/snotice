import 'package:flutter/material.dart';

import '../main/shell_dimensions.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: ShellDimensions.headerHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: ShellDimensions.headerHorizontalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: ShellDimensions.pageTitleSize,
              height: 1.2,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}
