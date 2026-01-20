import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';
import '../providers/server_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _portController = TextEditingController();
  final _ipController = TextEditingController();
  List<String> _allowedIPs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final config = context.read<ConfigProvider>().config;
        _portController.text = config.port.toString();
        setState(() {
          _allowedIPs = List.from(config.allowedIPs);
        });
      }
    });
  }

  @override
  void dispose() {
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final configProvider = context.read<ConfigProvider>();
      final serverProvider = context.read<ServerProvider>();

      final newConfig = configProvider.config.copyWith(
        port: int.parse(_portController.text),
        allowedIPs: _allowedIPs,
      );

      configProvider.updateConfig(newConfig);
      serverProvider.updateConfig(newConfig);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved')));
      Navigator.pop(context);
    }
  }

  void _addIP() {
    if (_ipController.text.isNotEmpty &&
        !_allowedIPs.contains(_ipController.text)) {
      setState(() {
        _allowedIPs.add(_ipController.text);
        _ipController.clear();
      });
    }
  }

  void _removeIP(String ip) {
    setState(() {
      _allowedIPs.remove(ip);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<ConfigProvider>(
        builder: (context, configProvider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Server Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _portController,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.settings_ethernet),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a port';
                            }
                            final port = int.tryParse(value);
                            if (port == null || port < 1 || port > 65535) {
                              return 'Please enter a valid port (1-65535)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Auto Start'),
                          subtitle: const Text(
                            'Start server automatically on app launch',
                          ),
                          value: configProvider.config.autoStart,
                          onChanged: (value) {
                            configProvider.toggleAutoStart();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Allowed IPs',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () {
                                showDialog(
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
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ipController,
                                decoration: const InputDecoration(
                                  labelText: 'Add IP Address',
                                  border: OutlineInputBorder(),
                                  hintText: 'e.g., 127.0.0.1 or 192.168.1.0/24',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _addIP,
                              icon: const Icon(Icons.add),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_allowedIPs.isEmpty)
                          const Text(
                            'No IPs added. All IPs will be allowed.',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allowedIPs.map((ip) {
                              return Chip(
                                label: Text(ip),
                                onDeleted: () => _removeIP(ip),
                                deleteIcon: const Icon(Icons.close),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notification Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Show Notifications'),
                          subtitle: const Text('Display system notifications'),
                          value: configProvider.config.showNotifications,
                          onChanged: (value) {
                            configProvider.toggleShowNotifications();
                          },
                        ),
                      ],
                    ),
                  ),
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
          );
        },
      ),
    );
  }
}
