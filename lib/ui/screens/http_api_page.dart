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
    final port = context.select<ConfigProvider, int>((provider) {
      return provider.config.port;
    });

    final baseUrl = 'http://localhost:$port';
    final notifyUrl = '$baseUrl/api/notify';

    return Container(
      decoration: _buildTerminalBackground(context),
      child: Column(
        children: [
          const _ScanlineOverlay(),
          PageHeader(title: l10n.navHttpApi, trailing: _buildPortBadge(port)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(ShellDimensions.pagePadding),
              children: [
                _HeroTerminal(baseUrl: baseUrl),
                const SizedBox(height: 16),
                _ApiEndpointsSection(),
                const SizedBox(height: 16),
                _CodeExamplesSection(notifyUrl: notifyUrl),
                const SizedBox(height: 16),
                _ParametersGrid(),
                const SizedBox(height: 16),
                _ResponseExamplesSection(port: port),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildTerminalBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF0A0E14) : const Color(0xFFF5F5F0),
    );
  }

  Widget _buildPortBadge(int port) {
    return _TerminalBadge(label: 'PORT:$port', color: const Color(0xFF00FF9F));
  }
}

class _ScanlineOverlay extends StatelessWidget {
  const _ScanlineOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: Container(height: 0));
  }
}

class _TerminalBadge extends StatelessWidget {
  const _TerminalBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _HeroTerminal extends StatelessWidget {
  const _HeroTerminal({required this.baseUrl});

  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _TerminalWindow(
      title: '~/snotice/api',
      color: const Color(0xFF00D9FF),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTerminalPrompt(
              '>',
              'API_ENDPOINT',
              baseUrl,
              const Color(0xFFFF6B9D),
            ),
            const SizedBox(height: 12),
            _buildTerminalPrompt(
              '>',
              'METHOD',
              'POST / GET',
              const Color(0xFFFFB800),
            ),
            const SizedBox(height: 12),
            _buildTerminalPrompt(
              '>',
              'FORMAT',
              'application/json',
              const Color(0xFF9D4EDD),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUS: ONLINE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: const Color(0xFF00FF9F),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.httpApiIntroBody,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalPrompt(
    String symbol,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          symbol,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TerminalWindow extends StatelessWidget {
  const _TerminalWindow({
    required this.title,
    required this.color,
    required this.child,
  });

  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : const Color(0xFFFFFFFF),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _WindowButton(color: const Color(0xFFFF5F56)),
                const SizedBox(width: 8),
                _WindowButton(color: const Color(0xFFFFBD2E)),
                const SizedBox(width: 8),
                _WindowButton(color: const Color(0xFF27C93F)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 0,
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
        color: const Color(0xFF00FF9F),
      ),
      _EndpointData(
        method: 'POST',
        path: '/api/notify',
        description: l10n.httpApiEndpointNotifyDesc,
        color: const Color(0xFFFF6B9D),
      ),
      _EndpointData(
        method: 'GET',
        path: '/api/config',
        description: l10n.httpApiEndpointGetConfigDesc,
        color: const Color(0xFFFFB800),
      ),
      _EndpointData(
        method: 'POST',
        path: '/api/config',
        description: l10n.httpApiEndpointUpdateConfigDesc,
        color: const Color(0xFF9D4EDD),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.httpApiEndpointListTitle,
          color: const Color(0xFF00D9FF),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.black.withValues(alpha: 0.02),
        border: Border.all(
          color: endpoint.color.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: endpoint.color.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: endpoint.color.withValues(alpha: 0.2),
                  border: Border.all(color: endpoint.color),
                ),
                child: Text(
                  endpoint.method,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: endpoint.color,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SelectableText(
                  endpoint.path,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            endpoint.description,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 2,
        ),
      ),
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
        _SectionHeader(
          title: l10n.httpApiExamples,
          color: const Color(0xFFFF6B9D),
        ),
        const SizedBox(height: 12),
        _CodeExample(
          title: 'GET /api/status',
          color: const Color(0xFF00FF9F),
          code: 'curl http://localhost:8642/api/status',
        ),
        const SizedBox(height: 12),
        _CodeExample(
          title: l10n.httpApiNotifyNormal,
          color: const Color(0xFFFF6B9D),
          code: '''curl -X POST $notifyUrl \\
  -H "Content-Type: application/json" \\
  -d '{"title": "Hello", "body": "From SNotice", "priority": "normal"}' ''',
        ),
        const SizedBox(height: 12),
        _CodeExample(
          title: 'POST /api/notify (barrage)',
          color: const Color(0xFFFFB800),
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

class _CodeExample extends StatelessWidget {
  const _CodeExample({
    required this.title,
    required this.color,
    required this.code,
  });

  final String title;
  final Color color;
  final String code;

  @override
  Widget build(BuildContext context) {
    return _TerminalWindow(
      title: title,
      color: color,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.5,
            color: Color(0xFFE0E0E0),
          ),
        ),
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
        _SectionHeader(
          title: l10n.httpApiNotifyParamsTitle,
          color: const Color(0xFF9D4EDD),
        ),
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
        const SizedBox(height: 16),
        _SectionHeader(
          title: l10n.httpApiConfigParamsTitle,
          color: const Color(0xFFFFB800),
        ),
        const SizedBox(height: 12),
        _buildParamsList([
          _ParamData(
            'port',
            'int',
            l10n.httpApiRequiredNo,
            l10n.httpApiParamPortDesc,
          ),
          _ParamData(
            'allowedIPs',
            'string[]',
            l10n.httpApiRequiredNo,
            l10n.httpApiParamAllowedIPsDesc,
          ),
          _ParamData(
            'defaultBarrageRepeat',
            'int',
            l10n.httpApiRequiredNo,
            'Default barrage repeat (1-8)',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRequired =
        param.required.toLowerCase().contains('yes') ||
        param.required.contains('是');
    final color = isRequired
        ? const Color(0xFFFF6B9D)
        : const Color(0xFF00D9FF);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.black.withValues(alpha: 0.02),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color),
                ),
                child: Text(
                  param.name,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                param.type,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isRequired
                      ? const Color(0xFFFF6B9D).withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
                child: Text(
                  param.required,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isRequired ? const Color(0xFFFF6B9D) : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            param.description,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
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
        _SectionHeader(
          title: l10n.httpApiResponseTitle,
          color: const Color(0xFF00FF9F),
        ),
        const SizedBox(height: 12),
        _CodeExample(
          title: 'GET /api/status → 200 OK',
          color: const Color(0xFF00FF9F),
          code: jsonEncoder.convert({
            'running': true,
            'port': port,
            'uptime': 128,
          }),
        ),
        const SizedBox(height: 12),
        _CodeExample(
          title: 'POST /api/notify → 200 OK',
          color: const Color(0xFFFF6B9D),
          code: jsonEncoder.convert({
            'success': true,
            'message': 'Notification sent',
            'timestamp': '2026-03-06T12:34:56.789Z',
          }),
        ),
        const SizedBox(height: 12),
        _CodeExample(
          title: 'POST /api/notify → 400 Bad Request',
          color: const Color(0xFFFF6B9D),
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
