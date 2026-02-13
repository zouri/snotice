import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_config.dart';
import '../providers/config_provider.dart';
import '../providers/server_provider.dart';
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
      ).showSnackBar(const SnackBar(content: Text('Failed to save settings')));
      return;
    }

    configProvider.updateConfig(newConfig);
    serverProvider.updateConfig(newConfig);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved')));
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
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('IP Whitelist'),
        content: const Text(
          'Only IPs in this list can send notifications. Leave empty to allow all IPs.\n\nYou can use:\n- Exact IP: 127.0.0.1\n- CIDR range: 192.168.1.0/24\n\nCIDR notation allows entire network ranges to be allowed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
