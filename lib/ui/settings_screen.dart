import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/app_config.dart';
import '../providers/config_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/server_provider.dart';
import '../providers/theme_provider.dart';
import '../services/config_service.dart';
import 'widgets/settings/allowed_ips_card.dart';
import 'widgets/settings/notification_settings_card.dart';
import 'widgets/settings/server_settings_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _portController = TextEditingController();
  final _ipController = TextEditingController();
  late AppConfig _initialConfig;
  List<String> _allowedIPs = const [];
  bool _autoStart = true;
  bool _showNotifications = true;

  @override
  void initState() {
    super.initState();
    final config = context.read<ConfigProvider>().config;
    _initialConfig = config;
    _portController.text = config.port.toString();
    _allowedIPs = List.from(config.allowedIPs);
    _autoStart = config.autoStart;
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
      autoStart: _autoStart,
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

    configProvider.updateConfig(newConfig);
    serverProvider.updateConfig(newConfig);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
    Navigator.pop(context);
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ServerSettingsCard(
              portController: _portController,
              autoStart: _autoStart,
              onAutoStartChanged: (value) {
                setState(() {
                  _autoStart = value;
                });
              },
            ),
            const SizedBox(height: 16),
            AllowedIpsCard(
              ipController: _ipController,
              allowedIps: _allowedIPs,
              onAddIp: _addIP,
              onRemoveIp: _removeIP,
              onShowInfo: _showIpWhitelistInfo,
            ),
            const SizedBox(height: 16),
            NotificationSettingsCard(
              showNotifications: _showNotifications,
              onShowNotificationsChanged: (value) {
                setState(() {
                  _showNotifications = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildThemeCard(context),
            const SizedBox(height: 16),
            _buildLanguageCard(context, l10n),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text(
                  l10n.settingsSave,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>().locale;
    final isZh = (locale?.languageCode ?? 'en').toLowerCase().startsWith('zh');

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ThemeMode.values.map((mode) {
                return ChoiceChip(
                  avatar: Icon(iconFor(mode), size: 16),
                  label: Text(labelFor(mode)),
                  selected: themeProvider.mode == mode,
                  onSelected: (selected) {
                    if (selected) {
                      themeProvider.setMode(mode);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
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
