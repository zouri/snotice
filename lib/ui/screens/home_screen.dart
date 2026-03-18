import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/app_config.dart';
import '../../providers/config_provider.dart';
import '../../providers/server_provider.dart';
import '../../services/config_service.dart';
import '../../services/startup_service.dart';
import '../widgets/common/page_header.dart';
import '../widgets/main/shell_dimensions.dart';
import '../widgets/settings/allowed_ips_card.dart';
import '../widgets/settings/auto_launch_settings_card.dart';
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
  final _ipController = TextEditingController();
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
    _barrageColorController.text = config.defaultBarrageColor;
    _barrageDurationController.text = config.defaultBarrageDuration.toString();
    _barrageSpeedController.text = config.defaultBarrageSpeed.toString();
    _barrageFontSizeController.text = config.defaultBarrageFontSize.toString();
    _barrageRepeatController.text = config.defaultBarrageRepeat.toString();
  }

  @override
  void dispose() {
    _portController.dispose();
    _ipController.dispose();
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
    final barrageColor = _barrageColorController.text.trim();
    final barrageDuration = int.tryParse(
      _barrageDurationController.text.trim(),
    );
    final barrageSpeed = double.tryParse(_barrageSpeedController.text.trim());
    final barrageFontSize = double.tryParse(
      _barrageFontSizeController.text.trim(),
    );
    final barrageRepeat = int.tryParse(_barrageRepeatController.text.trim());

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

  void _addIP() {
    final input = _ipController.text.trim();
    if (input.isEmpty || _draftConfig.allowedIPs.contains(input)) {
      return;
    }

    setState(() {
      _draftConfig = _draftConfig.copyWith(
        allowedIPs: [..._draftConfig.allowedIPs, input],
      );
      _ipController.clear();
    });
  }

  void _removeIP(String ip) {
    setState(() {
      _draftConfig = _draftConfig.copyWith(
        allowedIPs: _draftConfig.allowedIPs
            .where((item) => item != ip)
            .toList(),
      );
    });
  }

  void _showIpWhitelistInfo() {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ipWhitelistTitle),
        content: Text(l10n.ipWhitelistInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final serverProvider = context.watch<ServerProvider>();

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          PageHeader(title: l10n.settingsTitle),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1180;
                final leftColumnChildren = <Widget>[
                  if (!serverProvider.isRunning ||
                      serverProvider.lastError != null) ...[
                    ServerStatusCard(
                      isRunning: serverProvider.isRunning,
                      error: serverProvider.lastError,
                      onStart: () async {
                        if (!serverProvider.isRunning) {
                          await serverProvider.start();
                        }
                      },
                    ),
                    const SizedBox(height: ShellDimensions.sectionGap),
                  ],
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
                        AllowedIpsCard(
                          ipController: _ipController,
                          allowedIps: _draftConfig.allowedIPs,
                          onAddIp: _addIP,
                          onRemoveIp: _removeIP,
                          onShowInfo: _showIpWhitelistInfo,
                        ),
                        const SizedBox(height: ShellDimensions.sectionGap),
                        NotificationSettingsCard(
                          showNotifications: _draftConfig.showNotifications,
                          showBarrage: _draftConfig.showBarrage,
                          onShowNotificationsChanged: (value) {
                            setState(() {
                              _draftConfig = _draftConfig.copyWith(
                                showNotifications: value,
                              );
                            });
                          },
                          onShowBarrageChanged: (value) {
                            setState(() {
                              _draftConfig = _draftConfig.copyWith(
                                showBarrage: value,
                              );
                            });
                          },
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
                      ],
                    ),
                  ),
                ];

                final rightColumnChildren = <Widget>[
                  const ThemeSettingsCard(),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  const LanguageSettingsCard(),
                  const SizedBox(height: ShellDimensions.sectionGap),
                  SizedBox(
                    width: double.infinity,
                    height: ShellDimensions.buttonHeight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        textStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              fontSize: ShellDimensions.buttonTextSize,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      onPressed: _saveSettings,
                      child: Text(l10n.settingsSave),
                    ),
                  ),
                ];

                if (!isWide) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      ShellDimensions.pagePadding,
                      0,
                      ShellDimensions.pagePadding,
                      ShellDimensions.pagePadding,
                    ),
                    children: [
                      ...leftColumnChildren,
                      const SizedBox(height: ShellDimensions.sectionGap),
                      ...rightColumnChildren,
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
                          children: leftColumnChildren,
                        ),
                      ),
                      const SizedBox(width: ShellDimensions.pagePadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: rightColumnChildren,
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
