import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/config_provider.dart';
import '../../theme/app_colors.dart';
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

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          PageHeader(
            title: l10n.navHttpApi,
            trailing: _buildPortBadge(context, port),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(ShellDimensions.pagePadding),
              children: [
                _HeroCard(baseUrl: baseUrl),
                const SizedBox(height: ShellDimensions.sectionGap),
                _ApiEndpointsSection(),
                const SizedBox(height: ShellDimensions.sectionGap),
                _CodeExamplesSection(notifyUrl: notifyUrl),
                const SizedBox(height: ShellDimensions.sectionGap),
                _ParametersGrid(),
                const SizedBox(height: ShellDimensions.sectionGap),
                _ResponseExamplesSection(port: port),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortBadge(BuildContext context, int port) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.router_outlined, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            '$port',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.baseUrl});

  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.httpApiIntroTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.httpApiIntroBody,
              style: textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoChip(
                  icon: Icons.link,
                  label: l10n.httpApiBaseUrlLabel,
                  value: baseUrl,
                ),
                _InfoChip(
                  icon: Icons.data_object,
                  label: l10n.httpApiContentTypeLabel,
                  value: 'application/json',
                ),
                _InfoChip(
                  icon: Icons.security_outlined,
                  label: l10n.httpApiAuthLabel,
                  value: l10n.httpApiAuthValue,
                  isCompact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.isCompact = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(minWidth: isCompact ? 0 : 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiEndpointsSection extends StatelessWidget {
  const _ApiEndpointsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final endpoints = [
      _EndpointData(
        method: 'GET',
        path: '/api/status',
        description: l10n.httpApiEndpointStatusDesc,
        color: AppColors.info,
      ),
      _EndpointData(
        method: 'POST',
        path: '/api/notify',
        description: l10n.httpApiEndpointNotifyDesc,
        color: AppColors.primary,
      ),
      _EndpointData(
        method: 'GET',
        path: '/api/config',
        description: l10n.httpApiEndpointGetConfigDesc,
        color: AppColors.info,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.httpApiEndpointListTitle),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            if (isWide) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: endpoints
                    .map(
                      (e) => SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: _EndpointCard(endpoint: e),
                      ),
                    )
                    .toList(),
              );
            }
            return Column(
              children: endpoints
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EndpointCard(endpoint: e),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _EndpointData {
  const _EndpointData({
    required this.method,
    required this.path,
    required this.description,
    required this.color,
  });

  final String method;
  final String path;
  final String description;
  final Color color;
}

class _EndpointCard extends StatelessWidget {
  const _EndpointCard({required this.endpoint});

  final _EndpointData endpoint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
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
                  color: endpoint.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  endpoint.method,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: endpoint.color,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SelectableText(
                  endpoint.path,
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            endpoint.description,
            style: textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontSize: ShellDimensions.cardTitleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CodeExamplesSection extends StatelessWidget {
  const _CodeExamplesSection({required this.notifyUrl});

  final String notifyUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.httpApiExamples),
        const SizedBox(height: 12),
        _CodeBlock(
          title: 'GET /api/status',
          code: 'curl http://localhost:8642/api/status',
        ),
        const SizedBox(height: 10),
        _CodeBlock(
          title: l10n.httpApiNotifyNormal,
          code: '''curl -X POST $notifyUrl \\
  -H "Content-Type: application/json" \\
  -d '{"title": "Hello", "body": "From SNotice", "priority": "normal"}' ''',
        ),
        const SizedBox(height: 10),
        _CodeBlock(
          title: 'POST /api/notify (barrage)',
          code: '''curl -X POST $notifyUrl \\
  -H "Content-Type: application/json" \\
  -d '{
    "title": "Alert",
    "body": "API出现3次失败",
    "category": "barrage",
    "barrageColor": "#FFD84D",
    "barrageDuration": 6000,
    "barrageSpeed": 160,
    "barrageFontSize": 30,
    "barrageLane": "top",
    "barrageRepeat": 3
  }' ''',
        ),
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.title, required this.code});

  final String title;
  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.03),
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              code,
              style: textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParametersGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.httpApiNotifyParamsTitle),
        const SizedBox(height: 12),
        _buildParamsList([
          _ParamData(
            'title',
            'string',
            l10n.httpApiRequiredYes,
            l10n.httpApiParamTitleDesc,
          ),
          _ParamData(
            'body',
            'string',
            l10n.httpApiRequiredConditional,
            l10n.httpApiParamBodyDesc,
          ),
          _ParamData(
            'category',
            'string',
            l10n.httpApiRequiredNo,
            'flash_full / flash_edge / barrage',
          ),
          _ParamData(
            'barrageRepeat',
            'int',
            l10n.httpApiRequiredNo,
            'Barrage repeat count (1-8)',
          ),
        ]),
      ],
    );
  }

  Widget _buildParamsList(List<_ParamData> params) {
    return Column(
      children: params
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ParamRow(param: p),
            ),
          )
          .toList(),
    );
  }
}

class _ParamData {
  const _ParamData(this.name, this.type, this.required, this.description);

  final String name;
  final String type;
  final String required;
  final String description;
}

class _ParamRow extends StatelessWidget {
  const _ParamRow({required this.param});

  final _ParamData param;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRequired =
        param.required.toLowerCase().contains('yes') ||
        param.required.contains('是');
    final requiredColor = isRequired ? AppColors.error : AppColors.textHint;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  param.name,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                param.type,
                style: textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: requiredColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  param.required,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: requiredColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            param.description,
            style: textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseExamplesSection extends StatelessWidget {
  const _ResponseExamplesSection({required this.port});

  final int port;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final jsonEncoder = const JsonEncoder.withIndent('  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.httpApiResponseTitle),
        const SizedBox(height: 12),
        _CodeBlock(
          title: 'GET /api/status → 200 OK',
          code: jsonEncoder.convert({
            'running': true,
            'port': port,
            'uptime': 128,
          }),
        ),
        const SizedBox(height: 10),
        _CodeBlock(
          title: 'POST /api/notify → 200 OK',
          code: jsonEncoder.convert({
            'success': true,
            'message': 'Notification sent',
            'timestamp': '2026-03-06T12:34:56.789Z',
          }),
        ),
        const SizedBox(height: 10),
        _CodeBlock(
          title: 'POST /api/notify → 400 Bad Request',
          code: jsonEncoder.convert({
            'success': false,
            'error': 'Invalid notification request.',
            'validationErrors': [
              'Field "category" must be one of: flash_full, flash_edge, barrage.',
            ],
          }),
        ),
      ],
    );
  }
}
