import 'package:flutter/material.dart';

import '../../../theme/app_text_styles.dart';
import '../main/shell_dimensions.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineLg.copyWith(
                      fontSize: ShellDimensions.pageTitleSize,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
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
