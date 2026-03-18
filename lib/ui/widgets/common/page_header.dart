import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';
import '../main/shell_dimensions.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: ShellDimensions.headerHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ShellDimensions.pagePadding,
          0,
          ShellDimensions.pagePadding,
          0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineLg.copyWith(
                  fontSize: ShellDimensions.pageTitleSize,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              DefaultTextStyle(
                style: AppTextStyles.bodySm.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                child: trailing!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
