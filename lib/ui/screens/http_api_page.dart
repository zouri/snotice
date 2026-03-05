import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/config_provider.dart';
import '../widgets/main/shell_dimensions.dart';

class HttpApiPage extends StatelessWidget {
  const HttpApiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final port = context.select<ConfigProvider, int>((provider) {
      return provider.config.port;
    });

    final statusUrl = 'http://localhost:$port/api/status';
    final notifyUrl = 'http://localhost:$port/api/notify';

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          _buildPageHeader(context, l10n.navHttpApi),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(ShellDimensions.pagePadding),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(ShellDimensions.cardPadding),
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Endpoints',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: ShellDimensions.cardTitleSize,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            'GET $statusUrl',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: ShellDimensions.codeSize,
                                  fontFamily: 'monospace',
                                ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            'POST $notifyUrl',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: ShellDimensions.codeSize,
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(ShellDimensions.cardPadding),
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Examples',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: ShellDimensions.cardTitleSize,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'POST /api/notify (normal)',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: ShellDimensions.bodySize,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            'curl -X POST $notifyUrl -H "Content-Type: application/json" '
                            '-d "{\\"title\\":\\"Hello\\",\\"body\\":\\"From SNotice\\"}"',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: ShellDimensions.codeSize,
                                  fontFamily: 'monospace',
                                  height: 1.35,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'POST /api/notify (flash)',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: ShellDimensions.bodySize,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            'curl -X POST $notifyUrl -H "Content-Type: application/json" '
                            '-d "{\\"title\\":\\"Alert\\",\\"body\\":\\"Flash\\",\\"category\\":\\"flash\\",\\"flashColor\\":\\"#FF0000\\",\\"flashDuration\\":700,\\"flashEffect\\":\\"edge\\"}"',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: ShellDimensions.codeSize,
                                  fontFamily: 'monospace',
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

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
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: ShellDimensions.pageTitleSize,
          height: 1.2,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
