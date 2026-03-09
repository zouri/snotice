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
      'category': 'flash_full',
      'flashColor': '#FF0000',
      'flashDuration': 700,
    };
    final flashEdgePayloadMap = <String, dynamic>{
      'title': l10n.httpApiSampleTitleAlert,
      'category': 'flash_edge',
      'flashColor': '#35D6FF',
      'flashDuration': 900,
      'edgeWidth': 16,
      'edgeOpacity': 0.9,
      'edgeRepeat': 2,
    };
    final barragePayloadMap = <String, dynamic>{
      'title': l10n.httpApiSampleTitleAlert,
      'body': '当前接口出现 3 次失败，请尽快处理',
      'category': 'barrage',
      'barrageColor': '#FFD84D',
      'barrageDuration': 6000,
      'barrageSpeed': 160,
      'barrageFontSize': 30,
      'barrageLane': 'top',
      'barrageRepeat': 3,
    };
    final updateConfigPayloadMap = <String, dynamic>{
      'port': port,
      'allowedIPs': ['127.0.0.1', '192.168.1.0/24'],
      'autoStart': true,
      'showNotifications': true,
      'showBarrage': true,
      'defaultBarrageColor': '#FFD84D',
      'defaultBarrageDuration': 6000,
      'defaultBarrageSpeed': 120,
      'defaultBarrageFontSize': 28,
      'defaultBarrageLane': 'top',
      'defaultBarrageRepeat': 1,
    };

    final statusCurlCommand = 'curl $baseUrl/api/status';
    final normalCurlCommand =
        'curl -X POST $notifyUrl -H "Content-Type: application/json" -d '
        "'${jsonEncode(normalPayloadMap)}'";
    final flashEdgeCurlCommand =
        'curl -X POST $notifyUrl -H "Content-Type: application/json" -d '
        "'${jsonEncode(flashEdgePayloadMap)}'";
    final flashFullCurlCommand =
        'curl -X POST $notifyUrl -H "Content-Type: application/json" -d '
        "'${jsonEncode(flashFullPayloadMap)}'";
    final barrageCurlCommand =
        'curl -X POST $notifyUrl -H "Content-Type: application/json" -d '
        "'${jsonEncode(barragePayloadMap)}'";
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
        'Field "category" must be one of: flash_full, flash_edge, barrage.',
      ],
    });

    final endpoints = <_EndpointSpec>[
      _EndpointSpec(
        method: 'GET',
        path: '/api/status',
        description: l10n.httpApiEndpointStatusDesc,
      ),
      _EndpointSpec(
        method: 'POST',
        path: '/api/notify',
        description: l10n.httpApiEndpointNotifyDesc,
      ),
      _EndpointSpec(
        method: 'GET',
        path: '/api/config',
        description: l10n.httpApiEndpointGetConfigDesc,
      ),
      _EndpointSpec(
        method: 'POST',
        path: '/api/config',
        description: l10n.httpApiEndpointUpdateConfigDesc,
      ),
    ];

    final notifyParams = <_ApiParamSpec>[
      _ApiParamSpec(
        name: 'title',
        type: 'string',
        required: l10n.httpApiRequiredYes,
        description: l10n.httpApiParamTitleDesc,
      ),
      _ApiParamSpec(
        name: 'body',
        type: 'string',
        required: l10n.httpApiRequiredConditional,
        description:
            'Notification body. Required for normal notifications; optional when category=flash_full, flash_edge, or barrage.',
      ),
      _ApiParamSpec(
        name: 'priority',
        type: 'string',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamPriorityDesc,
      ),
      _ApiParamSpec(
        name: 'category',
        type: 'string',
        required: l10n.httpApiRequiredNo,
        description:
            'Notification category. Allowed: flash_full / flash_edge / barrage.',
      ),
      _ApiParamSpec(
        name: 'flashColor',
        type: 'string',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamFlashColorDesc,
      ),
      _ApiParamSpec(
        name: 'flashDuration',
        type: 'int',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamFlashDurationDesc,
      ),
      _ApiParamSpec(
        name: 'edgeWidth',
        type: 'double',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamEdgeWidthDesc,
      ),
      _ApiParamSpec(
        name: 'edgeOpacity',
        type: 'double',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamEdgeOpacityDesc,
      ),
      _ApiParamSpec(
        name: 'edgeRepeat',
        type: 'int',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamEdgeRepeatDesc,
      ),
      const _ApiParamSpec(
        name: 'barrageColor',
        type: 'string',
        required: 'No',
        description:
            'Barrage text color in hex or named color. Only valid when category=barrage.',
      ),
      const _ApiParamSpec(
        name: 'barrageDuration',
        type: 'int',
        required: 'No',
        description:
            'Barrage total duration in milliseconds. Only valid when category=barrage.',
      ),
      const _ApiParamSpec(
        name: 'barrageSpeed',
        type: 'double',
        required: 'No',
        description: 'Barrage speed in px/s. Only valid when category=barrage.',
      ),
      const _ApiParamSpec(
        name: 'barrageFontSize',
        type: 'double',
        required: 'No',
        description: 'Barrage font size. Only valid when category=barrage.',
      ),
      const _ApiParamSpec(
        name: 'barrageLane',
        type: 'string',
        required: 'No',
        description:
            'Barrage lane: top | middle | bottom. Only valid when category=barrage.',
      ),
      const _ApiParamSpec(
        name: 'barrageRepeat',
        type: 'int',
        required: 'No',
        description:
            'Barrage repeat count (1-8). Only valid when category=barrage.',
      ),
      _ApiParamSpec(
        name: 'payload',
        type: 'object',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamPayloadDesc,
      ),
    ];

    final configParams = <_ApiParamSpec>[
      _ApiParamSpec(
        name: 'port',
        type: 'int',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamPortDesc,
      ),
      _ApiParamSpec(
        name: 'allowedIPs',
        type: 'string[]',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamAllowedIPsDesc,
      ),
      _ApiParamSpec(
        name: 'autoStart',
        type: 'bool',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamAutoStartDesc,
      ),
      _ApiParamSpec(
        name: 'showNotifications',
        type: 'bool',
        required: l10n.httpApiRequiredNo,
        description: l10n.httpApiParamShowNotificationsDesc,
      ),
      const _ApiParamSpec(
        name: 'showBarrage',
        type: 'bool',
        required: 'No',
        description: 'Whether barrage overlay notifications are enabled.',
      ),
      const _ApiParamSpec(
        name: 'defaultBarrageColor',
        type: 'string',
        required: 'No',
        description: 'Default barrage text color.',
      ),
      const _ApiParamSpec(
        name: 'defaultBarrageDuration',
        type: 'int',
        required: 'No',
        description: 'Default barrage total duration in milliseconds.',
      ),
      const _ApiParamSpec(
        name: 'defaultBarrageSpeed',
        type: 'double',
        required: 'No',
        description: 'Default barrage speed in px/s.',
      ),
      const _ApiParamSpec(
        name: 'defaultBarrageFontSize',
        type: 'double',
        required: 'No',
        description: 'Default barrage font size.',
      ),
      const _ApiParamSpec(
        name: 'defaultBarrageLane',
        type: 'string',
        required: 'No',
        description: 'Default barrage lane: top | middle | bottom.',
      ),
      const _ApiParamSpec(
        name: 'defaultBarrageRepeat',
        type: 'int',
        required: 'No',
        description: 'Default barrage repeat count (1-8).',
      ),
    ];

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          PageHeader(title: l10n.navHttpApi),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(ShellDimensions.pagePadding),
              children: [
                _HeroCard(
                  title: l10n.httpApiIntroTitle,
                  description: l10n.httpApiIntroBody,
                  baseUrlLabel: l10n.httpApiBaseUrlLabel,
                  baseUrl: baseUrl,
                  contentTypeLabel: l10n.httpApiContentTypeLabel,
                  contentType: 'application/json',
                  authLabel: l10n.httpApiAuthLabel,
                  authValue: l10n.httpApiAuthValue,
                  endpointCount: endpoints.length,
                  sampleCount: 5,
                  port: port,
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _SectionCard(
                  title: l10n.httpApiExamples,
                  subtitle: l10n.httpApiEndpoints,
                  child: SelectionArea(
                    child: Column(
                      children: [
                        _QuickStartStep(
                          index: 1,
                          title: 'GET /api/status',
                          description: l10n.httpApiEndpointStatusDesc,
                          code: statusCurlCommand,
                        ),
                        const SizedBox(height: 8),
                        _QuickStartStep(
                          index: 2,
                          title: l10n.httpApiNotifyNormal,
                          description: l10n.httpApiEndpointNotifyDesc,
                          code: normalCurlCommand,
                        ),
                        const SizedBox(height: 8),
                        _QuickStartStep(
                          index: 3,
                          title: l10n.httpApiExampleFlashEdge,
                          description: l10n.httpApiEnumCategory,
                          code: flashEdgeCurlCommand,
                        ),
                        const SizedBox(height: 8),
                        _QuickStartStep(
                          index: 4,
                          title: 'POST /api/notify (barrage)',
                          description: 'Send scrolling barrage overlay alert',
                          code: barrageCurlCommand,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _SectionCard(
                  title: l10n.httpApiEndpointListTitle,
                  child: _EndpointGrid(items: endpoints),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _SectionCard(
                  title: l10n.httpApiNotifyParamsTitle,
                  child: _ParamList(items: notifyParams),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _SectionCard(
                  title: l10n.httpApiConfigParamsTitle,
                  child: _ParamList(items: configParams),
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 920;
                    final enumCard = _SectionCard(
                      title: l10n.httpApiEnumTitle,
                      child: Column(
                        children: [
                          _EnumRow(
                            name: 'category',
                            values: 'flash_full | flash_edge | barrage',
                            description:
                                'flash_full: full-screen flash; flash_edge: edge glow; barrage: scrolling overlay text.',
                          ),
                          const SizedBox(height: 8),
                          _EnumRow(
                            name: 'priority',
                            values: 'low | normal | high',
                            description: l10n.httpApiEnumPriority,
                          ),
                        ],
                      ),
                    );
                    final notesCard = _SectionCard(
                      title: l10n.httpApiNotesTitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NoteLine(text: l10n.httpApiNotesAliases),
                          const SizedBox(height: 6),
                          const _NoteLine(
                            text:
                                'flash_full / flash_edge / barrage allow empty body; normal notifications must include body.',
                          ),
                          const SizedBox(height: 6),
                          _NoteLine(text: l10n.httpApiNotesEdgeOnly),
                          const SizedBox(height: 6),
                          const _NoteLine(
                            text:
                                'barrageColor/barrageDuration/barrageSpeed/barrageFontSize/barrageLane/barrageRepeat only work when category=barrage.',
                          ),
                        ],
                      ),
                    );

                    if (!wide) {
                      return Column(
                        children: [
                          enumCard,
                          const SizedBox(height: ShellDimensions.sectionGap),
                          notesCard,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: enumCard),
                        const SizedBox(width: ShellDimensions.sectionGap),
                        Expanded(child: notesCard),
                      ],
                    );
                  },
                ),
                const SizedBox(height: ShellDimensions.sectionGap),
                _SectionCard(
                  title: l10n.httpApiResponseTitle,
                  child: SelectionArea(
                    child: Column(
                      children: [
                        _LabeledCodeBlock(
                          label: l10n.httpApiExampleFlashFull,
                          code: flashFullCurlCommand,
                        ),
                        const SizedBox(height: 8),
                        _LabeledCodeBlock(
                          label: 'POST /api/notify（弹幕 barrage）',
                          code: barrageCurlCommand,
                        ),
                        const SizedBox(height: 8),
                        _LabeledCodeBlock(
                          label: l10n.httpApiExampleConfigUpdate,
                          code: updateConfigCurlCommand,
                        ),
                        const SizedBox(height: 8),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.description,
    required this.baseUrlLabel,
    required this.baseUrl,
    required this.contentTypeLabel,
    required this.contentType,
    required this.authLabel,
    required this.authValue,
    required this.endpointCount,
    required this.sampleCount,
    required this.port,
  });

  final String title;
  final String description;
  final String baseUrlLabel;
  final String baseUrl;
  final String contentTypeLabel;
  final String contentType;
  final String authLabel;
  final String authValue;
  final int endpointCount;
  final int sampleCount;
  final int port;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ShellDimensions.radiusMd),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.72),
            colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(ShellDimensions.cardPadding + 3),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 860;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: ShellDimensions.pageTitleSize,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: ShellDimensions.bodySize,
                  height: 1.55,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(label: baseUrlLabel, value: baseUrl),
                  _MetaChip(label: contentTypeLabel, value: contentType),
                  _MetaChip(label: authLabel, value: authValue),
                ],
              ),
            ],
          );

          final right = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(label: 'Endpoints', value: '$endpointCount'),
              _StatChip(label: 'Examples', value: '$sampleCount'),
              _StatChip(label: 'Port', value: '$port'),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, const SizedBox(height: 10), right],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: left),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Align(alignment: Alignment.topRight, child: right),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(ShellDimensions.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: ShellDimensions.metaSize,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: textTheme.bodySmall?.copyWith(
              fontSize: ShellDimensions.codeSize,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 118,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.08),
          colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(ShellDimensions.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: ShellDimensions.metaSize,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontSize: ShellDimensions.cardTitleSize,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding + 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: ShellDimensions.cardTitleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: ShellDimensions.metaSize,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _QuickStartStep extends StatelessWidget {
  const _QuickStartStep({
    required this.index,
    required this.title,
    required this.description,
    required this.code,
  });

  final int index;
  final String title;
  final String description;
  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(ShellDimensions.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: ShellDimensions.bodySize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: ShellDimensions.bodySmallSize,
                        height: 1.45,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _CodeBlock(code: code),
        ],
      ),
    );
  }
}

class _EndpointSpec {
  const _EndpointSpec({
    required this.method,
    required this.path,
    required this.description,
  });

  final String method;
  final String path;
  final String description;
}

class _EndpointGrid extends StatelessWidget {
  const _EndpointGrid({required this.items});

  final List<_EndpointSpec> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 920;
        if (!twoColumns) {
          return Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _EndpointCard(item: items[i]),
                if (i != items.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              SizedBox(
                width: (constraints.maxWidth - 8) / 2,
                child: _EndpointCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _EndpointCard extends StatelessWidget {
  const _EndpointCard({required this.item});

  final _EndpointSpec item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ShellDimensions.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainerLowest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MethodBadge(method: item.method),
              const SizedBox(width: 8),
              Expanded(
                child: SelectableText(
                  item.path,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: ShellDimensions.codeSize,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: textTheme.bodySmall?.copyWith(
              fontSize: ShellDimensions.bodySmallSize,
              height: 1.45,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isGet = method.toUpperCase() == 'GET';
    final background = isGet
        ? Color.alphaBlend(
            colorScheme.tertiary.withValues(alpha: 0.16),
            colorScheme.surface,
          )
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.16),
            colorScheme.surface,
          );
    final foreground = isGet ? colorScheme.tertiary : colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        method,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: ShellDimensions.metaSize,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class _ApiParamSpec {
  const _ApiParamSpec({
    required this.name,
    required this.type,
    required this.required,
    required this.description,
  });

  final String name;
  final String type;
  final String required;
  final String description;
}

class _ParamList extends StatelessWidget {
  const _ParamList({required this.items});

  final List<_ApiParamSpec> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _ParamRow(item: items[i]),
          if (i != items.length - 1) const SizedBox(height: 7),
        ],
      ],
    );
  }
}

class _ParamRow extends StatelessWidget {
  const _ParamRow({required this.item});

  final _ApiParamSpec item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final requiredColor =
        item.required.toLowerCase().contains('yes') ||
            item.required.contains('是')
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ShellDimensions.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  item.name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: ShellDimensions.codeSize,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _Badge(
                label: item.type,
                foregroundColor: colorScheme.primary,
                backgroundColor: Color.alphaBlend(
                  colorScheme.primary.withValues(alpha: 0.12),
                  colorScheme.surface,
                ),
              ),
              const SizedBox(width: 6),
              _Badge(
                label: item.required,
                foregroundColor: requiredColor,
                backgroundColor: Color.alphaBlend(
                  requiredColor.withValues(alpha: 0.1),
                  colorScheme.surface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            item.description,
            style: textTheme.bodySmall?.copyWith(
              fontSize: ShellDimensions.bodySmallSize,
              height: 1.48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: backgroundColor,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: ShellDimensions.metaSize,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class _EnumRow extends StatelessWidget {
  const _EnumRow({
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(ShellDimensions.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            '$name: $values',
            style: textTheme.bodySmall?.copyWith(
              fontSize: ShellDimensions.codeSize,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              fontSize: ShellDimensions.bodySmallSize,
              height: 1.45,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
          height: 1.4,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(Icons.circle, size: 6, color: colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: ShellDimensions.bodySize,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
