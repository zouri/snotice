import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../providers/config_provider.dart';
import '../providers/log_provider.dart';
import 'settings_screen.dart';
import 'log_screen.dart';
import 'test_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNotice'), centerTitle: true),
      body: Consumer3<ServerProvider, ConfigProvider, LogProvider>(
        builder: (context, serverProvider, configProvider, logProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServerStatusCard(context, serverProvider, configProvider),
                const SizedBox(height: 20),
                _buildQuickActions(context, serverProvider),
                const SizedBox(height: 20),
                _buildStatsCard(logProvider),
                const SizedBox(height: 20),
                Expanded(child: _buildNavigation(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServerStatusCard(
    BuildContext context,
    ServerProvider serverProvider,
    ConfigProvider configProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  serverProvider.isRunning ? Icons.cloud_done : Icons.cloud_off,
                  color: serverProvider.isRunning ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serverProvider.isRunning
                            ? 'Server Running'
                            : 'Server Stopped',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Port: ${configProvider.config.port}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ServerProvider serverProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: serverProvider.isRunning
                ? () => _stopServer(context, serverProvider)
                : () => _startServer(context, serverProvider),
            icon: Icon(
              serverProvider.isRunning ? Icons.stop : Icons.play_arrow,
            ),
            label: Text(
              serverProvider.isRunning ? 'Stop Server' : 'Start Server',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: serverProvider.isRunning
                  ? Colors.red
                  : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestScreen()),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Test'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(LogProvider logProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Requests',
              logProvider.logs
                  .where((l) => l.type == 'REQUEST')
                  .length
                  .toString(),
              Icons.http,
              Colors.blue,
            ),
            _buildStatItem(
              'Notifications',
              logProvider.logs
                  .where((l) => l.type == 'NOTIFICATION')
                  .length
                  .toString(),
              Icons.notifications,
              Colors.green,
            ),
            _buildStatItem(
              'Errors',
              logProvider.logs
                  .where((l) => l.type == 'ERROR')
                  .length
                  .toString(),
              Icons.error,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildNavigation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('Logs'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogScreen()),
            );
          },
        ),
      ],
    );
  }

  Future<void> _startServer(
    BuildContext context,
    ServerProvider serverProvider,
  ) async {
    try {
      await serverProvider.start();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Server started')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start server: $e')));
      }
    }
  }

  Future<void> _stopServer(
    BuildContext context,
    ServerProvider serverProvider,
  ) async {
    try {
      await serverProvider.stop();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Server stopped')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop server: $e')));
      }
    }
  }
}
