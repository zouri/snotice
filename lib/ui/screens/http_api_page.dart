import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/config_provider.dart';
import '../widgets/common/page_header.dart';
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
    final normalPayload = jsonEncode({
      'title': l10n.httpApiSampleTitleHello,
      'body': l10n.httpApiSampleBodyFromSnotice,
    });
    final flashPayload = jsonEncode({
      'title': l10n.httpApiSampleTitleAlert,
      'body': l10n.httpApiSampleBodyFlash,
      'category': 'flash',
      'flashColor': '#FF0000',
      'flashDuration': 700,
      'flashEffect': 'edge',
    });
    final normalCurlCommand =
        "curl -X POST $notifyUrl -H \"Content-Type: application/json\" -d '$normalPayload'";
    final flashCurlCommand =
        "curl -X POST $notifyUrl -H \"Content-Type: application/json\" -d '$flashPayload'";

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          PageHeader(title: l10n.navHttpApi),
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
                            l10n.httpApiEndpoints,
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
                            l10n.httpApiExamples,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: ShellDimensions.cardTitleSize,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.httpApiNotifyNormal,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: ShellDimensions.bodySize,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            normalCurlCommand,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: ShellDimensions.codeSize,
                                  fontFamily: 'monospace',
                                  height: 1.35,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.httpApiNotifyFlash,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: ShellDimensions.bodySize,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            flashCurlCommand,
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
}
