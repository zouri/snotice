import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/app_config.dart';
import '../../models/notification_request.dart';
import '../../providers/config_provider.dart';
import '../../providers/server_provider.dart';
import '../../theme/app_animation.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../widgets/common/page_header.dart';
import '../widgets/main/shell_dimensions.dart';

enum _NotificationTestVariant { standard, flashFull, flashEdge, barrage }

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final JsonEncoder _prettyJson = const JsonEncoder.withIndent('  ');
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _iconController = TextEditingController();
  final _payloadController = TextEditingController();
  final _flashColorController = TextEditingController();
  final _flashDurationController = TextEditingController();
  final _edgeWidthController = TextEditingController();
  final _edgeOpacityController = TextEditingController();
  final _edgeRepeatController = TextEditingController();
  final _barrageColorController = TextEditingController();
  final _barrageDurationController = TextEditingController();
  final _barrageSpeedController = TextEditingController();
  final _barrageFontSizeController = TextEditingController();
  final _barrageRepeatController = TextEditingController();

  NotificationPriority _priority = NotificationPriority.normal;
  NotificationBarrageLane _barrageLane = NotificationBarrageLane.top;
  _NotificationTestVariant _variant = _NotificationTestVariant.standard;
  bool _isSending = false;
  _ResponseSnapshot? _lastResponse;

  @override
  void initState() {
    super.initState();
    final config = context.read<ConfigProvider>().config;
    _applyDefaults(config);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _iconController.dispose();
    _payloadController.dispose();
    _flashColorController.dispose();
    _flashDurationController.dispose();
    _edgeWidthController.dispose();
    _edgeOpacityController.dispose();
    _edgeRepeatController.dispose();
    _barrageColorController.dispose();
    _barrageDurationController.dispose();
    _barrageSpeedController.dispose();
    _barrageFontSizeController.dispose();
    _barrageRepeatController.dispose();
    super.dispose();
  }

  void _applyDefaults(AppConfig config) {
    _titleController.text = 'Build Complete';
    _messageController.text = 'Triggered from SNotice test lab';
    _iconController.clear();
    _payloadController.clear();
    _flashColorController.text = config.defaultFlashColor;
    _flashDurationController.text = config.defaultFlashDuration.toString();
    _edgeWidthController.text = config.defaultFlashEdgeWidth.toString();
    _edgeOpacityController.text = config.defaultFlashEdgeOpacity.toString();
    _edgeRepeatController.text = config.defaultFlashEdgeRepeat.toString();
    _barrageColorController.text = config.defaultBarrageColor;
    _barrageDurationController.text = config.defaultBarrageDuration.toString();
    _barrageSpeedController.text = config.defaultBarrageSpeed.toString();
    _barrageFontSizeController.text = config.defaultBarrageFontSize.toString();
    _barrageRepeatController.text = config.defaultBarrageRepeat.toString();
    _priority = NotificationPriority.normal;
    _barrageLane =
        NotificationBarrageLane.tryParse(config.defaultBarrageLane) ??
        NotificationBarrageLane.top;
    _variant = _NotificationTestVariant.standard;
    _lastResponse = null;
  }

  Future<void> _copyCurl(_PreviewData preview, AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: preview.curlCommand));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.notificationTestCopiedCurl)));
  }

  Future<void> _sendTest(
    _PreviewData preview,
    AppLocalizations l10n,
    int port,
  ) async {
    final serverProvider = context.read<ServerProvider>();

    if (!_isMountedServerReady(serverProvider)) {
      await serverProvider.start();
      if (!mounted) {
        return;
      }
      if (!_isMountedServerReady(serverProvider)) {
        final message =
            serverProvider.lastError ?? l10n.notificationTestServiceStartFailed;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }
    }

    setState(() {
      _isSending = true;
    });

    try {
      final response = await _postRequest(preview.payload, port);
      if (!mounted) {
        return;
      }

      setState(() {
        _lastResponse = response;
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.notificationTestSent)));
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = l10n.notificationTestBuildError(error.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  bool _isMountedServerReady(ServerProvider serverProvider) {
    return mounted && serverProvider.isRunning;
  }

  Future<_ResponseSnapshot> _postRequest(
    Map<String, dynamic> payload,
    int port,
  ) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);

    try {
      final request = await client.postUrl(
        Uri.parse('http://127.0.0.1:$port/api/notify'),
      );
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));

      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      final responseBody = await utf8.decodeStream(response);
      return _ResponseSnapshot(
        statusCode: response.statusCode,
        body: _formatJsonOrPlainText(responseBody),
      );
    } finally {
      client.close(force: true);
    }
  }

  String _formatJsonOrPlainText(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return '';
    }

    try {
      final decoded = jsonDecode(responseBody);
      return _prettyJson.convert(decoded);
    } catch (_) {
      return responseBody;
    }
  }

  _PreviewData _buildPreview(AppLocalizations l10n, int port) {
    final payload = _buildPayload(l10n);
    final prettyPayload = _prettyJson.convert(payload);
    final curlEndpoint = 'http://localhost:$port/api/notify';
    return _PreviewData(
      payload: payload,
      prettyPayload: prettyPayload,
      curlCommand: _buildCurlCommand(curlEndpoint, payload),
    );
  }

  Map<String, dynamic> _buildPayload(AppLocalizations l10n) {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final icon = _iconController.text.trim();
    final payloadText = _payloadController.text.trim();
    final requestPayload = <String, dynamic>{
      'title': title,
      'priority': _priority.value,
    };

    if (message.isNotEmpty || _variant == _NotificationTestVariant.standard) {
      requestPayload['message'] = message;
    }

    switch (_variant) {
      case _NotificationTestVariant.standard:
        break;
      case _NotificationTestVariant.flashFull:
        requestPayload['category'] = NotificationCategory.flashFull.value;
        _putIfParsedString(requestPayload, 'flashColor', _flashColorController);
        _putIfParsedInt(
          requestPayload,
          'flashDuration',
          _flashDurationController,
          l10n.flashDurationLabel,
          l10n,
        );
      case _NotificationTestVariant.flashEdge:
        requestPayload['category'] = NotificationCategory.flashEdge.value;
        _putIfParsedString(requestPayload, 'flashColor', _flashColorController);
        _putIfParsedInt(
          requestPayload,
          'flashDuration',
          _flashDurationController,
          l10n.flashDurationLabel,
          l10n,
        );
        _putIfParsedDouble(
          requestPayload,
          'edgeWidth',
          _edgeWidthController,
          l10n.flashEdgeWidthLabel,
          l10n,
        );
        _putIfParsedDouble(
          requestPayload,
          'edgeOpacity',
          _edgeOpacityController,
          l10n.flashEdgeOpacityLabel,
          l10n,
        );
        _putIfParsedInt(
          requestPayload,
          'edgeRepeat',
          _edgeRepeatController,
          l10n.flashEdgeRepeatLabel,
          l10n,
        );
      case _NotificationTestVariant.barrage:
        requestPayload['category'] = NotificationCategory.barrage.value;
        _putIfParsedString(
          requestPayload,
          'barrageColor',
          _barrageColorController,
        );
        _putIfParsedInt(
          requestPayload,
          'barrageDuration',
          _barrageDurationController,
          l10n.barrageDurationLabel,
          l10n,
        );
        _putIfParsedDouble(
          requestPayload,
          'barrageSpeed',
          _barrageSpeedController,
          l10n.barrageSpeedLabel,
          l10n,
        );
        _putIfParsedDouble(
          requestPayload,
          'barrageFontSize',
          _barrageFontSizeController,
          l10n.barrageFontSizeLabel,
          l10n,
        );
        requestPayload['barrageLane'] = _barrageLane.value;
        _putIfParsedInt(
          requestPayload,
          'barrageRepeat',
          _barrageRepeatController,
          l10n.barrageRepeatLabel,
          l10n,
        );
    }

    if (icon.isNotEmpty) {
      requestPayload['icon'] = icon;
    }

    if (payloadText.isNotEmpty) {
      final decoded = _decodePayloadJson(payloadText, l10n);
      requestPayload['payload'] = decoded;
    }

    final validationErrors = NotificationRequest.fromJson(
      requestPayload,
    ).validate();
    if (validationErrors.isNotEmpty) {
      throw FormatException(validationErrors.join('\n'));
    }

    return requestPayload;
  }

  Map<String, dynamic> _decodePayloadJson(
    String payloadText,
    AppLocalizations l10n,
  ) {
    dynamic decoded;
    try {
      decoded = jsonDecode(payloadText);
    } on FormatException {
      throw FormatException(l10n.notificationTestInvalidJson);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    throw FormatException(l10n.notificationTestPayloadMustBeObject);
  }

  void _putIfParsedString(
    Map<String, dynamic> payload,
    String key,
    TextEditingController controller,
  ) {
    final value = controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    payload[key] = value;
  }

  void _putIfParsedInt(
    Map<String, dynamic> payload,
    String key,
    TextEditingController controller,
    String label,
    AppLocalizations l10n,
  ) {
    final value = controller.text.trim();
    if (value.isEmpty) {
      return;
    }

    final parsed = int.tryParse(value);
    if (parsed == null) {
      throw FormatException(l10n.notificationTestInvalidNumber(label));
    }
    payload[key] = parsed;
  }

  void _putIfParsedDouble(
    Map<String, dynamic> payload,
    String key,
    TextEditingController controller,
    String label,
    AppLocalizations l10n,
  ) {
    final value = controller.text.trim();
    if (value.isEmpty) {
      return;
    }

    final parsed = double.tryParse(value);
    if (parsed == null) {
      throw FormatException(l10n.notificationTestInvalidNumber(label));
    }
    payload[key] = parsed;
  }

  String _buildCurlCommand(String endpoint, Map<String, dynamic> payload) {
    final encoded = jsonEncode(payload).replaceAll("'", r"'\''");
    return '''curl -X POST $endpoint \\
  -H "Content-Type: application/json" \\
  --data-raw '$encoded' ''';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = context.watch<ConfigProvider>().config;
    final port = context.select<ConfigProvider, int>((provider) {
      return provider.config.port;
    });
    final isServerRunning = context.select<ServerProvider, bool>((provider) {
      return provider.isRunning;
    });
    final brightness = Theme.of(context).brightness;
    final previewState = _PreviewState.from(
      builder: () => _buildPreview(l10n, port),
    );

    return ColoredBox(
      color: AppColors.workspaceBackgroundFor(brightness),
      child: Column(
        children: [
          PageHeader(
            title: l10n.notificationTestTitle,
            subtitle: l10n.notificationTestSubtitle,
            trailing: Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _StatusBadge(
                  label: isServerRunning
                      ? l10n.trayServiceRunning
                      : l10n.notificationTestServerStopped,
                  running: isServerRunning,
                ),
                _StatusBadge(
                  label: 'PORT $port',
                  running: true,
                  accentOnly: true,
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1160;
                final leftColumn = [
                  _SectionCard(
                    title: l10n.notificationTestRequestCardTitle,
                    subtitle: l10n.notificationTestRequestCardDesc,
                    child: Column(
                      children: [
                        _LabeledField(
                          label: l10n.notificationTestEffectTypeLabel,
                          child: _VariantSelector(
                            variant: _variant,
                            l10n: l10n,
                            onChanged: (variant) {
                              setState(() {
                                _variant = variant;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _AdaptiveFields(
                          children: [
                            _buildTextField(
                              controller: _titleController,
                              label: l10n.labelTitle,
                            ),
                            _buildTextField(
                              controller: _messageController,
                              label: l10n.message,
                              maxLines: 3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _AdaptiveFields(
                          children: [
                            _buildPriorityField(l10n),
                            _buildTextField(
                              controller: _iconController,
                              label: l10n.notificationTestIconLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _payloadController,
                          label: l10n.notificationTestPayloadLabel,
                          hintText: l10n.notificationTestPayloadHint,
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  _SectionCard(
                    title: l10n.notificationTestEffectCardTitle,
                    subtitle: l10n.notificationTestEffectCardDesc,
                    child: _buildEffectEditor(l10n),
                  ),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  _ActionCard(
                    l10n: l10n,
                    isBusy: _isSending,
                    canCopy: previewState.preview != null,
                    onSend: previewState.preview == null
                        ? null
                        : () => _sendTest(previewState.preview!, l10n, port),
                    onCopyCurl: previewState.preview == null
                        ? null
                        : () => _copyCurl(previewState.preview!, l10n),
                    onReset: () {
                      setState(() {
                        _applyDefaults(config);
                      });
                    },
                  ),
                ];

                final rightColumn = [
                  _SectionCard(
                    title: l10n.notificationTestPreviewCardTitle,
                    subtitle: l10n.notificationTestPreviewCardDesc,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoStrip(
                          title: l10n.notificationTestEndpointLabel,
                          body: 'http://localhost:$port/api/notify',
                          caption: l10n.notificationTestEndpointDesc,
                        ),
                        const SizedBox(height: 14),
                        if (previewState.error != null)
                          _ErrorSurface(
                            message:
                                '${l10n.notificationTestPreviewInvalid}\n${previewState.error!}',
                          )
                        else ...[
                          _CodePanel(
                            title: 'JSON',
                            code: previewState.preview!.prettyPayload,
                          ),
                          const SizedBox(height: 12),
                          _CodePanel(
                            title: 'cURL',
                            code: previewState.preview!.curlCommand,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  _SectionCard(
                    title: l10n.notificationTestResponseCardTitle,
                    child: _ResponsePanel(
                      response: _lastResponse,
                      emptyLabel: l10n.notificationTestResponseEmpty,
                      statusLabelBuilder: l10n.notificationTestResponseStatus,
                    ),
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
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: leftColumn,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
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

  Widget _buildEffectEditor(AppLocalizations l10n) {
    switch (_variant) {
      case _NotificationTestVariant.standard:
        return _HelperNotice(
          toneColor: AppColors.info,
          title: l10n.notificationTestNoExtraSettings,
        );
      case _NotificationTestVariant.flashFull:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelperNotice(
              toneColor: AppColors.warning,
              title: l10n.notificationTestLeaveBlankDefaults,
            ),
            const SizedBox(height: 14),
            _AdaptiveFields(
              children: [
                _buildTextField(
                  controller: _flashColorController,
                  label: l10n.flashColorLabel,
                ),
                _buildTextField(
                  controller: _flashDurationController,
                  label: l10n.flashDurationLabel,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ],
        );
      case _NotificationTestVariant.flashEdge:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelperNotice(
              toneColor: AppColors.warning,
              title: l10n.notificationTestLeaveBlankDefaults,
            ),
            const SizedBox(height: 14),
            _AdaptiveFields(
              children: [
                _buildTextField(
                  controller: _flashColorController,
                  label: l10n.flashColorLabel,
                ),
                _buildTextField(
                  controller: _flashDurationController,
                  label: l10n.flashDurationLabel,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  controller: _edgeWidthController,
                  label: l10n.flashEdgeWidthLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _buildTextField(
                  controller: _edgeOpacityController,
                  label: l10n.flashEdgeOpacityLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _buildTextField(
                  controller: _edgeRepeatController,
                  label: l10n.flashEdgeRepeatLabel,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ],
        );
      case _NotificationTestVariant.barrage:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelperNotice(
              toneColor: AppColors.primary,
              title: l10n.notificationTestLeaveBlankDefaults,
            ),
            const SizedBox(height: 14),
            _AdaptiveFields(
              children: [
                _buildTextField(
                  controller: _barrageColorController,
                  label: l10n.barrageColorLabel,
                ),
                _buildTextField(
                  controller: _barrageDurationController,
                  label: l10n.barrageDurationLabel,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  controller: _barrageSpeedController,
                  label: l10n.barrageSpeedLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _buildTextField(
                  controller: _barrageFontSizeController,
                  label: l10n.barrageFontSizeLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _buildLaneField(l10n),
                _buildTextField(
                  controller: _barrageRepeatController,
                  label: l10n.barrageRepeatLabel,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildPriorityField(AppLocalizations l10n) {
    return DropdownButtonFormField<NotificationPriority>(
      key: ValueKey(_priority),
      initialValue: _priority,
      decoration: InputDecoration(
        labelText: l10n.notificationPriorityLabel,
        border: const OutlineInputBorder(),
      ),
      items: NotificationPriority.values.map((priority) {
        return DropdownMenuItem<NotificationPriority>(
          value: priority,
          child: Text(priority.value),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _priority = value;
        });
      },
    );
  }

  Widget _buildLaneField(AppLocalizations l10n) {
    return DropdownButtonFormField<NotificationBarrageLane>(
      key: ValueKey(_barrageLane),
      initialValue: _barrageLane,
      decoration: InputDecoration(
        labelText: l10n.barrageLaneLabel,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: NotificationBarrageLane.top,
          child: Text(l10n.barrageLaneTop),
        ),
        DropdownMenuItem(
          value: NotificationBarrageLane.middle,
          child: Text(l10n.barrageLaneMiddle),
        ),
        DropdownMenuItem(
          value: NotificationBarrageLane.bottom,
          child: Text(l10n.barrageLaneBottom),
        ),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _barrageLane = value;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PreviewData {
  const _PreviewData({
    required this.payload,
    required this.prettyPayload,
    required this.curlCommand,
  });

  final Map<String, dynamic> payload;
  final String prettyPayload;
  final String curlCommand;
}

class _PreviewState {
  const _PreviewState({this.preview, this.error});

  factory _PreviewState.from({required _PreviewData Function() builder}) {
    try {
      return _PreviewState(preview: builder());
    } on FormatException catch (error) {
      return _PreviewState(error: error.message);
    }
  }

  final _PreviewData? preview;
  final String? error;
}

class _ResponseSnapshot {
  const _ResponseSnapshot({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
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
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: AppTextStyles.bodySm.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.l10n,
    required this.isBusy,
    required this.canCopy,
    required this.onSend,
    required this.onCopyCurl,
    required this.onReset,
  });

  final AppLocalizations l10n;
  final bool isBusy;
  final bool canCopy;
  final VoidCallback? onSend;
  final VoidCallback? onCopyCurl;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: isBusy ? null : onSend,
              icon: isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.notificationTestSendButton),
            ),
            OutlinedButton.icon(
              onPressed: canCopy ? onCopyCurl : null,
              icon: const Icon(Icons.content_copy_rounded),
              label: Text(l10n.notificationTestCopyCurlButton),
            ),
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.notificationTestResetButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdaptiveFields extends StatelessWidget {
  const _AdaptiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        if (!wide) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children.map((child) {
            return SizedBox(
              width: (constraints.maxWidth - 12) / 2,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _VariantSelector extends StatelessWidget {
  const _VariantSelector({
    required this.variant,
    required this.l10n,
    required this.onChanged,
  });

  final _NotificationTestVariant variant;
  final AppLocalizations l10n;
  final ValueChanged<_NotificationTestVariant> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_NotificationTestVariant>(
      segments: [
        ButtonSegment(
          value: _NotificationTestVariant.standard,
          label: Text(l10n.notificationTestEffectStandard),
          icon: const Icon(Icons.notifications_active_rounded),
        ),
        ButtonSegment(
          value: _NotificationTestVariant.flashFull,
          label: Text(l10n.notificationTestEffectFlashFull),
          icon: const Icon(Icons.flash_on_rounded),
        ),
        ButtonSegment(
          value: _NotificationTestVariant.flashEdge,
          label: Text(l10n.notificationTestEffectFlashEdge),
          icon: const Icon(Icons.crop_free_rounded),
        ),
        ButtonSegment(
          value: _NotificationTestVariant.barrage,
          label: Text(l10n.notificationTestEffectBarrage),
          icon: const Icon(Icons.view_timeline_rounded),
        ),
      ],
      selected: {variant},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.title, required this.body, this.caption});

  final String title;
  final String body;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerFor(brightness),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.shellBorderFor(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMd.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTextStyles.code.copyWith(color: colorScheme.onSurface),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              style: AppTextStyles.bodySm.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CodePanel extends StatelessWidget {
  const _CodePanel({required this.title, required this.code});

  final String title;
  final String code;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerFor(brightness),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.shellBorderFor(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMd.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SelectionArea(
            child: Text(
              code,
              style: AppTextStyles.codeSm.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorSurface extends StatelessWidget {
  const _ErrorSurface({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AnimatedContainer(
      duration: AppAnimation.fast,
      curve: AppAnimation.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withValues(
          alpha: brightness == Brightness.dark ? 0.14 : 0.8,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.errorFor(brightness)),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodySm.copyWith(
          color: AppColors.errorFor(brightness),
        ),
      ),
    );
  }
}

class _HelperNotice extends StatelessWidget {
  const _HelperNotice({required this.toneColor, required this.title});

  final Color toneColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: toneColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMd.copyWith(color: toneColor)),
        ],
      ),
    );
  }
}

class _ResponsePanel extends StatelessWidget {
  const _ResponsePanel({
    required this.response,
    required this.emptyLabel,
    required this.statusLabelBuilder,
  });

  final _ResponseSnapshot? response;
  final String emptyLabel;
  final String Function(int status) statusLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;

    if (response == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerFor(brightness),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.shellBorderFor(brightness)),
        ),
        child: Text(
          emptyLabel,
          style: AppTextStyles.bodySm.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final success = response!.statusCode >= 200 && response!.statusCode < 300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HelperNotice(
          toneColor: success ? AppColors.success : AppColors.error,
          title: statusLabelBuilder(response!.statusCode),
        ),
        const SizedBox(height: 12),
        _CodePanel(title: 'Response', code: response!.body),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.running,
    this.accentOnly = false,
  });

  final String label;
  final bool running;
  final bool accentOnly;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = accentOnly
        ? AppColors.primary
        : running
        ? AppColors.successFor(brightness)
        : AppColors.errorFor(brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: AppTextStyles.labelMd.copyWith(color: color)),
    );
  }
}
