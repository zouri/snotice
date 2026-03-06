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
    final textTheme = Theme.of(context).textTheme;
    final port = context.select<ConfigProvider, int>((provider) {
      return provider.config.port;
    });

    final baseUrl = 'http://localhost:$port';
    final notifyUrl = '$baseUrl/api/notify';
    final configUrl = '$baseUrl/api/config';
    const jsonEncoder = JsonEncoder.withIndent('  ');

    final normalPayloadMap = <String, dynamic>{
      'title': l10n.httpApiSampleTitleHello,
      'body': l10n.httpApiSampleBodyFromSnotice,
      'priority': 'normal',
    };
    final flashFullPayloadMap = <String, dynamic>{
      'title': l10n.httpApiSampleTitleAlert,
      'body': l10n.httpApiSampleBodyFlash,
      'category': 'flash',
      'flashColor': '#FF0000',
      'flashDuration': 700,
      'flashEffect': 'full',
    };
    final flashEdgePayloadMap = <String, dynamic>{
      'title': l10n.httpApiSampleTitleAlert,
      'category': 'flash',
      'flashColor': '#35D6FF',
      'flashDuration': 900,
      'flashEffect': 'edge',
      'edgeWidth': 16,
      'edgeOpacity': 0.9,
      'edgeRepeat': 2,
    };
    final updateConfigPayloadMap = <String, dynamic>{
      'port': port,
      'allowedIPs': ['127.0.0.1', '192.168.1.0/24'],
      'autoStart': true,
      'showNotifications': true,
    };
    final normalCurlCommand =
        'curl -X POST $notifyUrl -H "Content-Type: application/json" -d '
        "'${jsonEncode(normalPayloadMap)}'";
    final flashFullCurlCommand =
        'curl -X POST $notifyUrl -H "Content-Type: application/json" -d '
        "'${jsonEncode(flashFullPayloadMap)}'";
    final flashEdgeCurlCommand =
        'curl -X POST $notifyUrl -H "Content-Type: application/json" -d '
        "'${jsonEncode(flashEdgePayloadMap)}'";
    final updateConfigCurlCommand =
        'curl -X POST $configUrl -H "Content-Type: application/json" -d '
        "'${jsonEncode(updateConfigPayloadMap)}'";

    final statusResponse = jsonEncoder.convert({
      'running': true,
      'port': port,
      'uptime': 128,
    });
    final notifySuccessResponse = jsonEncoder.convert({
      'success': true,
      'message': 'Notification sent',
      'timestamp': '2026-03-06T12:34:56.789Z',
    });
    final validationErrorResponse = jsonEncoder.convert({
      'success': false,
      'error': 'Invalid notification request.',
      'validationErrors': [
        'Field "flashEffect" must be one of: full, edge.',
      ],
    });

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          PageHeader(title: l10n.navHttpApi),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(ShellDimensions.pagePadding),
              children: [
                _DocCard(
                  title: l10n.httpApiIntroTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.httpApiIntroBody,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: ShellDimensions.bodySize,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MetaLine(
                        label: l10n.httpApiBaseUrlLabel,
                        value: baseUrl,
                        isCode: true,
                      ),
                      const SizedBox(height: 6),
                      _MetaLine(
                        label: l10n.httpApiContentTypeLabel,
                        value: 'application/json',
                        isCode: true,
                      ),
                      const SizedBox(height: 6),
                      _MetaLine(
                        label: l10n.httpApiAuthLabel,
                        value: l10n.httpApiAuthValue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _DocCard(
                  title: l10n.httpApiEndpointListTitle,
                  child: SelectionArea(
                    child: _SpecTable(
                      headers: [
                        l10n.httpApiEndpointMethod,
                        l10n.httpApiEndpointPath,
                        l10n.httpApiEndpointDesc,
                      ],
                      rows: [
                        [
                          'GET',
                          '/api/status',
                          l10n.httpApiEndpointStatusDesc,
                        ],
                        [
                          'POST',
                          '/api/notify',
                          l10n.httpApiEndpointNotifyDesc,
                        ],
                        [
                          'GET',
                          '/api/config',
                          l10n.httpApiEndpointGetConfigDesc,
                        ],
                        [
                          'POST',
                          '/api/config',
                          l10n.httpApiEndpointUpdateConfigDesc,
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _DocCard(
                  title: l10n.httpApiNotifyParamsTitle,
                  child: SelectionArea(
                    child: _SpecTable(
                      headers: [
                        l10n.httpApiParamName,
                        l10n.httpApiParamType,
                        l10n.httpApiParamRequired,
                        l10n.httpApiParamDescription,
                      ],
                      rows: [
                        [
                          'title',
                          'string',
                          l10n.httpApiRequiredYes,
                          l10n.httpApiParamTitleDesc,
                        ],
                        [
                          'body',
                          'string',
                          l10n.httpApiRequiredConditional,
                          l10n.httpApiParamBodyDesc,
                        ],
                        [
                          'priority',
                          'string',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamPriorityDesc,
                        ],
                        [
                          'category',
                          'string',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamCategoryDesc,
                        ],
                        [
                          'flashColor',
                          'string',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamFlashColorDesc,
                        ],
                        [
                          'flashDuration',
                          'int',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamFlashDurationDesc,
                        ],
                        [
                          'flashEffect',
                          'string',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamFlashEffectDesc,
                        ],
                        [
                          'edgeWidth',
                          'double',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamEdgeWidthDesc,
                        ],
                        [
                          'edgeOpacity',
                          'double',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamEdgeOpacityDesc,
                        ],
                        [
                          'edgeRepeat',
                          'int',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamEdgeRepeatDesc,
                        ],
                        [
                          'payload',
                          'object',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamPayloadDesc,
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _DocCard(
                  title: l10n.httpApiConfigParamsTitle,
                  child: SelectionArea(
                    child: _SpecTable(
                      headers: [
                        l10n.httpApiParamName,
                        l10n.httpApiParamType,
                        l10n.httpApiParamRequired,
                        l10n.httpApiParamDescription,
                      ],
                      rows: [
                        [
                          'port',
                          'int',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamPortDesc,
                        ],
                        [
                          'allowedIPs',
                          'string[]',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamAllowedIPsDesc,
                        ],
                        [
                          'autoStart',
                          'bool',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamAutoStartDesc,
                        ],
                        [
                          'showNotifications',
                          'bool',
                          l10n.httpApiRequiredNo,
                          l10n.httpApiParamShowNotificationsDesc,
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _DocCard(
                  title: l10n.httpApiEnumTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EnumLine(
                        name: 'category',
                        values: 'flash',
                        description: l10n.httpApiEnumCategory,
                      ),
                      const SizedBox(height: 8),
                      _EnumLine(
                        name: 'flashEffect',
                        values: 'full | edge',
                        description: l10n.httpApiEnumFlashEffect,
                      ),
                      const SizedBox(height: 8),
                      _EnumLine(
                        name: 'priority',
                        values: 'low | normal | high',
                        description: l10n.httpApiEnumPriority,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _DocCard(
                  title: l10n.httpApiExamples,
                  child: SelectionArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ExampleBlock(
                          title: l10n.httpApiNotifyNormal,
                          command: normalCurlCommand,
                          payload: jsonEncoder.convert(normalPayloadMap),
                        ),
                        const SizedBox(height: 10),
                        _ExampleBlock(
                          title: l10n.httpApiExampleFlashFull,
                          command: flashFullCurlCommand,
                          payload: jsonEncoder.convert(flashFullPayloadMap),
                        ),
                        const SizedBox(height: 10),
                        _ExampleBlock(
                          title: l10n.httpApiExampleFlashEdge,
                          command: flashEdgeCurlCommand,
                          payload: jsonEncoder.convert(flashEdgePayloadMap),
                        ),
                        const SizedBox(height: 10),
                        _ExampleBlock(
                          title: l10n.httpApiExampleConfigUpdate,
                          command: updateConfigCurlCommand,
                          payload: jsonEncoder.convert(updateConfigPayloadMap),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _DocCard(
                  title: l10n.httpApiResponseTitle,
                  child: SelectionArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LabeledCodeBlock(
                          label: 'GET /api/status',
                          code: statusResponse,
                        ),
                        const SizedBox(height: 8),
                        _LabeledCodeBlock(
                          label: l10n.httpApiResponseNotifySuccess,
                          code: notifySuccessResponse,
                        ),
                        const SizedBox(height: 8),
                        _LabeledCodeBlock(
                          label: l10n.httpApiResponseError,
                          code: validationErrorResponse,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _DocCard(
                  title: l10n.httpApiNotesTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NoteLine(text: l10n.httpApiNotesAliases),
                      const SizedBox(height: 6),
                      _NoteLine(text: l10n.httpApiNotesBodyOptional),
                      const SizedBox(height: 6),
                      _NoteLine(text: l10n.httpApiNotesEdgeOnly),
                    ],
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

class _DocCard extends StatelessWidget {
  const _DocCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: ShellDimensions.cardTitleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
    this.isCode = false,
  });

  final String label;
  final String value;
  final bool isCode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final valueStyle = isCode
        ? textTheme.bodySmall?.copyWith(
            fontSize: ShellDimensions.codeSize,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          )
        : textTheme.bodyMedium?.copyWith(
            fontSize: ShellDimensions.bodySize,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontSize: ShellDimensions.bodySmallSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

class _SpecTable extends StatelessWidget {
  const _SpecTable({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 880),
        child: Table(
          border: TableBorder.all(color: colorScheme.outlineVariant),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(1.4),
            1: FlexColumnWidth(1.1),
            2: FlexColumnWidth(1.1),
            3: FlexColumnWidth(4.4),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              children: headers.map((text) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    text,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: ShellDimensions.bodySmallSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
            ...rows.asMap().entries.map((entry) {
              final index = entry.key;
              final cols = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: index.isEven
                      ? colorScheme.surface
                      : colorScheme.surfaceContainerLowest,
                ),
                children: cols.map((cellText) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: SelectableText(
                      cellText,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: ShellDimensions.bodySmallSize,
                        height: 1.35,
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EnumLine extends StatelessWidget {
  const _EnumLine({
    required this.name,
    required this.values,
    required this.description,
  });

  final String name;
  final String values;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 220,
          child: SelectableText(
            '$name: $values',
            style: textTheme.bodySmall?.copyWith(
              fontSize: ShellDimensions.codeSize,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: ShellDimensions.bodySize,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  const _ExampleBlock({
    required this.title,
    required this.command,
    required this.payload,
  });

  final String title;
  final String command;
  final String payload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: ShellDimensions.bodySize,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        _CodeBlock(code: command),
        const SizedBox(height: 6),
        _CodeBlock(code: payload),
      ],
    );
  }
}

class _LabeledCodeBlock extends StatelessWidget {
  const _LabeledCodeBlock({required this.label, required this.code});

  final String label;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: ShellDimensions.bodySize,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        _CodeBlock(code: code),
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ShellDimensions.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(8),
      child: SelectableText(
        code,
        style: textTheme.bodySmall?.copyWith(
          fontSize: ShellDimensions.codeSize,
          fontFamily: 'monospace',
          height: 1.35,
        ),
      ),
    );
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.circle, size: 6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: ShellDimensions.bodySize,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
