import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/app_config.dart';
import '../../providers/config_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/server_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/config_service.dart';
import '../widgets/main/shell_dimensions.dart';
import '../widgets/settings/allowed_ips_card.dart';
import '../widgets/settings/notification_settings_card.dart';
import '../widgets/settings/server_settings_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _portController = TextEditingController();
  final _ipController = TextEditingController();

  late AppConfig _initialConfig;
  List<String> _allowedIPs = const [];
  bool _showNotifications = true;

  @override
  void initState() {
    super.initState();
    final config = context.read<ConfigProvider>().config;
    _initialConfig = config;
    _portController.text = config.port.toString();
    _allowedIPs = List.from(config.allowedIPs);
    _showNotifications = config.showNotifications;
  }

  @override
  void dispose() {
    _portController.dispose();
    _ipController.dispose();
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
    final l10n = AppLocalizations.of(context)!;

    final newConfig = _initialConfig.copyWith(
      port: port,
      allowedIPs: _allowedIPs,
      autoStart: true,
      showNotifications: _showNotifications,
    );

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

    _initialConfig = newConfig;
    configProvider.updateConfig(newConfig);
    serverProvider.updateConfig(newConfig);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
  }

  void _addIP() {
    final input = _ipController.text.trim();
    if (input.isEmpty || _allowedIPs.contains(input)) {
      return;
    }

    setState(() {
      _allowedIPs = [..._allowedIPs, input];
      _ipController.clear();
    });
  }

  void _removeIP(String ip) {
    setState(() {
      _allowedIPs = _allowedIPs.where((item) => item != ip).toList();
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

    return Consumer2<ServerProvider, ConfigProvider>(
      builder: (context, serverProvider, configProvider, _) {
        final config = configProvider.config;

        return Container(
          color: colorScheme.surface,
          child: Column(
            children: [
              _buildPageHeader(context, l10n.settingsTitle),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1180;
                    final leftColumnChildren = <Widget>[
                      _ServerCard(
                        isRunning: serverProvider.isRunning,
                        port: config.port,
                        error: serverProvider.lastError,
                        onToggle: () async {
                          if (serverProvider.isRunning) {
                            await serverProvider.stop();
                          } else {
                            await serverProvider.start();
                          }
                        },
                      ),
                      const SizedBox(height: ShellDimensions.sectionGap),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ServerSettingsCard(portController: _portController),
                            const SizedBox(height: ShellDimensions.sectionGap),
                            AllowedIpsCard(
                              ipController: _ipController,
                              allowedIps: _allowedIPs,
                              onAddIp: _addIP,
                              onRemoveIp: _removeIP,
                              onShowInfo: _showIpWhitelistInfo,
                            ),
                            const SizedBox(height: ShellDimensions.sectionGap),
                            NotificationSettingsCard(
                              showNotifications: _showNotifications,
                              onShowNotificationsChanged: (value) {
                                setState(() {
                                  _showNotifications = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ];

                    final rightColumnChildren = <Widget>[
                      _buildThemeCard(context),
                      const SizedBox(height: ShellDimensions.sectionGap),
                      _buildLanguageCard(context, l10n),
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
                        padding: const EdgeInsets.all(
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
                      padding: const EdgeInsets.all(
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
      },
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

  Widget _buildThemeCard(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode.toLowerCase().startsWith('zh');
    final colorScheme = Theme.of(context).colorScheme;

    final title = isZh ? '外观主题' : 'Theme';
    final subtitle = isZh ? '可切换浅色、深色或跟随系统' : 'Light, Dark, or follow system';

    String labelFor(ThemeMode mode) {
      if (!isZh) {
        switch (mode) {
          case ThemeMode.system:
            return 'System';
          case ThemeMode.light:
            return 'Light';
          case ThemeMode.dark:
            return 'Dark';
        }
      }

      switch (mode) {
        case ThemeMode.system:
          return '跟随系统';
        case ThemeMode.light:
          return '浅色';
        case ThemeMode.dark:
          return '深色';
      }
    }

    IconData iconFor(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return Icons.settings_suggest_outlined;
        case ThemeMode.light:
          return Icons.wb_sunny_outlined;
        case ThemeMode.dark:
          return Icons.dark_mode_outlined;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(ShellDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: ShellDimensions.cardTitleSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: ShellDimensions.bodySmallSize,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ThemeMode.values.map((mode) {
                  final selected = themeProvider.mode == mode;
                  final foreground = selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant;

                  return ChoiceChip(
                    showCheckmark: false,
                    selected: selected,
                    onSelected: (active) {
                      if (active) {
                        themeProvider.setMode(mode);
                      }
                    },
                    avatar: Icon(iconFor(mode), size: 16, color: foreground),
                    label: Text(
                      labelFor(mode),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: ShellDimensions.metaSize,
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: colorScheme.surface,
                    side: BorderSide(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                    shape: const StadiumBorder(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: ShellDimensions.cardTitleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Locale?>(
              initialValue: currentLocale,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: LocaleProvider.localeOptions.map((option) {
                return DropdownMenuItem<Locale?>(
                  value: option.locale,
                  child: Text(option.getLabel(currentLocale)),
                );
              }).toList(),
              onChanged: (locale) {
                localeProvider.setLocale(locale);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  const _ServerCard({
    required this.isRunning,
    required this.port,
    required this.error,
    required this.onToggle,
  });

  final bool isRunning;
  final int port;
  final String? error;
  final Future<void> Function() onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = isRunning ? colorScheme.tertiary : colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ShellDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isRunning ? l10n.statusRunning : l10n.statusStopped,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: ShellDimensions.bodySize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, ShellDimensions.buttonHeight),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: onToggle,
                  child: Text(
                    isRunning ? l10n.trayStopService : l10n.trayStartService,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: ShellDimensions.buttonTextSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'HTTP Port: $port',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ShellDimensions.bodySmallSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                error!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
