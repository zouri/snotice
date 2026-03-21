import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/app_config.dart';
import '../../providers/config_provider.dart';
import '../../providers/server_provider.dart';
import '../../services/config_service.dart';
import '../../services/startup_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../widgets/common/page_header.dart';
import '../widgets/main/shell_dimensions.dart';
import '../widgets/settings/auto_launch_settings_card.dart';
import '../widgets/settings/notification_defaults_card.dart';
import '../widgets/settings/language_settings_card.dart';
import '../widgets/settings/notification_settings_card.dart';
import '../widgets/settings/server_settings_card.dart';
import '../widgets/settings/server_status_card.dart';
import '../widgets/settings/theme_settings_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _portController = TextEditingController();
  final _flashColorController = TextEditingController();
  final _flashDurationController = TextEditingController();
  final _flashEdgeWidthController = TextEditingController();
  final _flashEdgeOpacityController = TextEditingController();
  final _flashEdgeRepeatController = TextEditingController();
  final _barrageColorController = TextEditingController();
  final _barrageDurationController = TextEditingController();
  final _barrageSpeedController = TextEditingController();
  final _barrageFontSizeController = TextEditingController();
  final _barrageRepeatController = TextEditingController();

  late AppConfig _draftConfig;
  late String _barrageLane;
  late final bool _startupSupported;

  @override
  void initState() {
    super.initState();
    final config = context.read<ConfigProvider>().config;
    _draftConfig = config;
    _startupSupported = context.read<StartupService>().isSupported;
    _barrageLane = config.defaultBarrageLane;
    _portController.text = config.port.toString();
    _flashColorController.text = config.defaultFlashColor;
    _flashDurationController.text = config.defaultFlashDuration.toString();
    _flashEdgeWidthController.text = config.defaultFlashEdgeWidth.toString();
    _flashEdgeOpacityController.text = config.defaultFlashEdgeOpacity
        .toString();
    _flashEdgeRepeatController.text = config.defaultFlashEdgeRepeat.toString();
    _barrageColorController.text = config.defaultBarrageColor;
    _barrageDurationController.text = config.defaultBarrageDuration.toString();
    _barrageSpeedController.text = config.defaultBarrageSpeed.toString();
    _barrageFontSizeController.text = config.defaultBarrageFontSize.toString();
    _barrageRepeatController.text = config.defaultBarrageRepeat.toString();
  }

  @override
  void dispose() {
    _portController.dispose();
    _flashColorController.dispose();
    _flashDurationController.dispose();
    _flashEdgeWidthController.dispose();
    _flashEdgeOpacityController.dispose();
    _flashEdgeRepeatController.dispose();
    _barrageColorController.dispose();
    _barrageDurationController.dispose();
    _barrageSpeedController.dispose();
    _barrageFontSizeController.dispose();
    _barrageRepeatController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final port = int.tryParse(_portController.text);
    if (port == null) {
      return;
    }

    final configProvider = context.read<ConfigProvider>();
    final serverProvider = context.read<ServerProvider>();
    final configService = context.read<ConfigService>();
    final startupService = context.read<StartupService>();
    final currentConfig = configProvider.config;
    final l10n = AppLocalizations.of(context)!;
    final flashColor = _flashColorController.text.trim();
    final flashDuration = int.tryParse(_flashDurationController.text.trim());
    final flashEdgeWidth = double.tryParse(
      _flashEdgeWidthController.text.trim(),
    );
    final flashEdgeOpacity = double.tryParse(
      _flashEdgeOpacityController.text.trim(),
    );
    final flashEdgeRepeat = int.tryParse(
      _flashEdgeRepeatController.text.trim(),
    );
    final barrageColor = _barrageColorController.text.trim();
    final barrageDuration = int.tryParse(
      _barrageDurationController.text.trim(),
    );
    final barrageSpeed = double.tryParse(_barrageSpeedController.text.trim());
    final barrageFontSize = double.tryParse(
      _barrageFontSizeController.text.trim(),
    );
    final barrageRepeat = int.tryParse(_barrageRepeatController.text.trim());

    final invalidFlashDefaults =
        flashColor.isEmpty ||
        flashDuration == null ||
        flashDuration <= 0 ||
        flashEdgeWidth == null ||
        flashEdgeWidth <= 0 ||
        flashEdgeOpacity == null ||
        flashEdgeOpacity < 0 ||
        flashEdgeOpacity > 1 ||
        flashEdgeRepeat == null ||
        flashEdgeRepeat <= 0;
    if (invalidFlashDefaults) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.flashConfigInvalid)));
      return;
    }

    final invalidBarrageDefaults =
        barrageColor.isEmpty ||
        barrageDuration == null ||
        barrageDuration <= 0 ||
        barrageSpeed == null ||
        barrageSpeed <= 0 ||
        barrageFontSize == null ||
        barrageFontSize <= 0 ||
        barrageRepeat == null ||
        barrageRepeat <= 0 ||
        barrageRepeat > AppConfig.maxBarrageRepeat;
    if (invalidBarrageDefaults) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.barrageConfigInvalid)));
      return;
    }

    final newConfig = _draftConfig.copyWith(
      port: port,
      autoLaunchOnLogin: _draftConfig.autoLaunchOnLogin,
      defaultFlashColor: flashColor,
      defaultFlashDuration: flashDuration,
      defaultFlashEdgeWidth: flashEdgeWidth,
      defaultFlashEdgeOpacity: flashEdgeOpacity,
      defaultFlashEdgeRepeat: flashEdgeRepeat,
      defaultBarrageColor: barrageColor,
      defaultBarrageDuration: barrageDuration,
      defaultBarrageSpeed: barrageSpeed,
      defaultBarrageFontSize: barrageFontSize,
      defaultBarrageLane: _barrageLane,
      defaultBarrageRepeat: barrageRepeat,
    );

    final autoLaunchOnLoginChanged =
        newConfig.autoLaunchOnLogin != currentConfig.autoLaunchOnLogin;
    if (autoLaunchOnLoginChanged && _startupSupported) {
      try {
        await startupService.setAutoLaunchOnLogin(newConfig.autoLaunchOnLogin);
      } catch (_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.autoLaunchOnLoginUpdateFailed)),
        );
        return;
      }
    }

    final configApplied = await serverProvider.applyConfig(
      newConfig,
      rollbackConfig: currentConfig,
    );
    if (!configApplied) {
      if (!mounted) {
        return;
      }
      final message = serverProvider.lastError ?? l10n.settingsSaveFailed;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    try {
      await configService.saveConfig(newConfig);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsSaveFailed)));
      return;
    }

    _draftConfig = newConfig;
    configProvider.updateConfig(newConfig);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serverProvider = context.watch<ServerProvider>();
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    final brightness = Theme.of(context).brightness;
    final subtitle = isZh
        ? '调整服务与通知投递的默认行为方式'
        : 'Adjust service behavior and local delivery defaults.';

    return ColoredBox(
      color: AppColors.workspaceBackgroundFor(brightness),
      child: Column(
        children: [
          PageHeader(
            title: l10n.settingsTitle,
            subtitle: subtitle,
            trailing: SizedBox(
              height: ShellDimensions.buttonHeight,
              child: FilledButton(
                onPressed: _saveSettings,
                child: Text(l10n.settingsSave),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1120;
                final leftColumn = _buildMainColumn(serverProvider);
                final rightColumn = _buildSideColumn(serverProvider, isZh);

                if (!isWide) {
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
                        width: 304,
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

  List<Widget> _buildMainColumn(ServerProvider serverProvider) {
    return [
      Form(
        key: _formKey,
        child: Column(
          children: [
            AutoLaunchSettingsCard(
              autoLaunchOnLogin: _draftConfig.autoLaunchOnLogin,
              startupSupported: _startupSupported,
              onAutoLaunchOnLoginChanged: (value) {
                setState(() {
                  _draftConfig = _draftConfig.copyWith(
                    autoLaunchOnLogin: value,
                  );
                });
              },
            ),
            const SizedBox(height: ShellDimensions.sectionGap),
            ServerSettingsCard(portController: _portController),
            const SizedBox(height: ShellDimensions.sectionGap),
            NotificationSettingsCard(
              showFlash: _draftConfig.showFlash,
              showBarrage: _draftConfig.showBarrage,
              showSound: _draftConfig.showSound,
              onShowFlashChanged: (value) {
                setState(() {
                  _draftConfig = _draftConfig.copyWith(showFlash: value);
                });
              },
              onShowBarrageChanged: (value) {
                setState(() {
                  _draftConfig = _draftConfig.copyWith(showBarrage: value);
                });
              },
              onShowSoundChanged: (value) {
                setState(() {
                  _draftConfig = _draftConfig.copyWith(showSound: value);
                });
              },
            ),
            const SizedBox(height: ShellDimensions.sectionGap),
            NotificationDefaultsCard(
              flashColorController: _flashColorController,
              flashDurationController: _flashDurationController,
              flashEdgeWidthController: _flashEdgeWidthController,
              flashEdgeOpacityController: _flashEdgeOpacityController,
              flashEdgeRepeatController: _flashEdgeRepeatController,
              barrageColorController: _barrageColorController,
              barrageDurationController: _barrageDurationController,
              barrageSpeedController: _barrageSpeedController,
              barrageFontSizeController: _barrageFontSizeController,
              barrageRepeatController: _barrageRepeatController,
              barrageLane: _barrageLane,
              onBarrageLaneChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _barrageLane = value;
                });
              },
            ),
            const SizedBox(height: ShellDimensions.sectionGap),
            if (!serverProvider.isRunning ||
                serverProvider.lastError != null) ...[
              const SizedBox(height: ShellDimensions.sectionGap),
              ServerStatusCard(
                isRunning: serverProvider.isRunning,
                error: serverProvider.lastError,
                onStart: () async {
                  if (!serverProvider.isRunning) {
                    await serverProvider.start();
                  }
                },
              ),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildSideColumn(ServerProvider serverProvider, bool isZh) {
    return [
      const ThemeSettingsCard(),
      const SizedBox(height: ShellDimensions.sectionGap),
      const LanguageSettingsCard(),
      const SizedBox(height: ShellDimensions.sectionGap),
      _InfoCard(
        title: isZh ? '调整建议' : 'Tips',
        body: isZh
            ? '开启弹幕提醒适合高频通知场景，关闭后只保留系统通知。\n如果修改了服务端口，外部脚本也需要同步更新调用地址。'
            : 'Barrage mode works best for high-frequency alerts. If you change the port, update your client scripts as well.',
      ),
      const SizedBox(height: ShellDimensions.sectionGap),
      _InfoCard(
        title: isZh ? '排查异常' : 'Troubleshooting',
        body: isZh
            ? '如果服务没有启动，请先检查端口是否被其他程序占用。'
            : 'If the server is not starting, check whether the configured port is already in use.',
        highlighted: true,
      ),
    ];
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    this.highlighted = false,
  });

  final String title;
  final String body;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: highlighted
          ? AppColors.primaryContainer.withValues(alpha: 0.55)
          : null,
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
            const SizedBox(height: 6),
            Text(
              body,
              style: AppTextStyles.bodySm.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
