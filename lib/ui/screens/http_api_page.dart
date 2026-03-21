import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/config_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../widgets/common/page_header.dart';
import '../widgets/main/shell_dimensions.dart';

class HttpApiPage extends StatelessWidget {
  const HttpApiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final port = context.select<ConfigProvider, int>((provider) {
      return provider.config.port;
    });
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    final brightness = Theme.of(context).brightness;

    final baseUrl = 'http://localhost:$port';
    final notifyUrl = '$baseUrl/api/notify';
    final mcpUrl = '$baseUrl/api/mcp';

    return ColoredBox(
      color: AppColors.workspaceBackgroundFor(brightness),
      child: Column(
        children: [
          PageHeader(
            title: l10n.navHttpApi,
            subtitle: isZh
                ? '本机 HTTP API 文档与 MCP 接入说明'
                : 'Local HTTP API docs and MCP integration guide.',
            trailing: _PortBadge(port: port),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1120;
                final leftColumn = [
                  _HeroCard(
                    title: l10n.httpApiIntroTitle,
                    body: l10n.httpApiIntroBody,
                    baseUrl: baseUrl,
                    authLabel: l10n.httpApiAuthLabel,
                    authValue: l10n.httpApiAuthValue,
                  ),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  _SectionCard(
                    title: l10n.httpApiEndpointListTitle,
                    child: Column(
                      children: [
                        _EndpointRow(
                          method: 'POST',
                          path: '/api/notify',
                          description: l10n.httpApiEndpointNotifyDesc,
                          methodColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  _SectionCard(
                    title: l10n.httpApiMcpSectionTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoLine(
                          label: l10n.httpApiMcpEndpointTitle,
                          value: 'POST $mcpUrl',
                        ),
                        const SizedBox(height: 12),
                        _CodeSurface(
                          title: l10n.httpApiMcpToolsTitle,
                          code: '''snotice_send_notification
snotice_get_status
snotice_get_config
snotice_update_config''',
                        ),
                        const SizedBox(height: 12),
                        _CodeSurface(
                          title: l10n.httpApiMcpExampleListTitle,
                          code: '''curl -X POST $mcpUrl \\
  -H "Content-Type: application/json" \\
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' ''',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  _SectionCard(
                    title: l10n.httpApiExamples,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CodeSurface(
                          title: 'curl',
                          code: '''curl -X POST $notifyUrl \\
  -H "Content-Type: application/json" \\
  -d '{"title":"Build Complete","message":"Deployment finished"}' ''',
                        ),
                      ],
                    ),
                  ),
                ];

                final rightColumn = [
                  _MiniSectionCard(
                    title: isZh ? '常用参数' : 'Key parameters',
                    rows: [
                      _MiniRowData(
                        'title',
                        isZh ? 'string，必填' : 'string, required',
                      ),
                      _MiniRowData(
                        'content',
                        isZh ? 'string，支持正文内容' : 'string body content',
                      ),
                      _MiniRowData(
                        'type',
                        isZh ? 'string，支持 flash / barrage' : 'string for flash / barrage',
                      ),
                      _MiniRowData(
                        'duration',
                        isZh ? 'number，单位毫秒' : 'number in milliseconds',
                      ),
                    ],
                  ),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  _MiniSectionCard(
                    title: isZh ? '响应示例' : 'Response example',
                    code: const JsonEncoder.withIndent('  ').convert({
                      'success': true,
                      'message': 'Notification sent successfully',
                      'port': 8642,
                    }),
                  ),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  _MiniSectionCard(
                    title: l10n.httpApiNotesTitle,
                    body: [
                      l10n.httpApiNotesAliases,
                      l10n.httpApiNotesBodyOptional,
                      l10n.httpApiNotesEdgeOnly,
                    ],
                  ),
                ];

                if (!wide) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      ShellDimensions.pagePadding,
                      0,
                      ShellDimensions.pagePadding,
                      ShellDimensions.pagePadding,
                    ),
                    children: [
                      ...leftColumn,
                      const SizedBox(height: ShellDimensions.sectionGap),
                      ...rightColumn,
                    ],
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    ShellDimensions.pagePadding,
                    0,
                    ShellDimensions.pagePadding,
                    ShellDimensions.pagePadding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: leftColumn,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 320,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: rightColumn,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PortBadge extends StatelessWidget {
  const _PortBadge({required this.port});

  final int port;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerFor(brightness),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.shellBorderFor(brightness)),
      ),
      child: Text(
        'PORT $port',
        style: AppTextStyles.labelMd.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.body,
    required this.baseUrl,
    required this.authLabel,
    required this.authValue,
  });

  final String title;
  final String body;
  final String baseUrl;
  final String authLabel;
  final String authValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: AppTextStyles.bodySm.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaChip(label: l10n.httpApiBaseUrlLabel, value: baseUrl),
                _MetaChip(
                  label: l10n.httpApiContentTypeLabel,
                  value: 'application/json',
                ),
                _MetaChip(label: authLabel, value: authValue),
              ],
            ),
          ],
        ),
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

    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: AppTextStyles.codeSm.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _EndpointRow extends StatelessWidget {
  const _EndpointRow({
    required this.method,
    required this.path,
    required this.description,
    required this.methodColor,
  });

  final String method;
  final String path;
  final String description;
  final Color methodColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: methodColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  method,
                  style: AppTextStyles.labelMd.copyWith(color: methodColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SelectableText(
                  path,
                  style: AppTextStyles.code.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodySm.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.bodySm.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: AppTextStyles.codeSm.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeSurface extends StatelessWidget {
  const _CodeSurface({required this.title, required this.code});

  final String title;
  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              title,
              style: AppTextStyles.labelMd.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SelectableText(
              code,
              style: AppTextStyles.codeSm.copyWith(
                color: colorScheme.onSurface,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSectionCard extends StatelessWidget {
  const _MiniSectionCard({
    required this.title,
    this.rows,
    this.code,
    this.body,
  });

  final String title;
  final List<_MiniRowData>? rows;
  final String? code;
  final List<String>? body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            if (rows != null) ...[
              const SizedBox(height: 10),
              ...rows!.map((row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MiniRow(row: row),
                );
              }),
            ],
            if (code != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: SelectableText(
                  code!,
                  style: AppTextStyles.codeSm.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
            if (body != null) ...[
              const SizedBox(height: 10),
              ...body!.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '• $item',
                    style: AppTextStyles.bodySm.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniRowData {
  const _MiniRowData(this.label, this.value);

  final String label;
  final String value;
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.row});

  final _MiniRowData row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.label,
            style: AppTextStyles.codeSm.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            row.value,
            style: AppTextStyles.bodySm.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
