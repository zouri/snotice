import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'REQUEST', child: Text('Requests')),
              const PopupMenuItem(
                value: 'NOTIFICATION',
                child: Text('Notifications'),
              ),
              const PopupMenuItem(value: 'ERROR', child: Text('Errors')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _showClearLogsDialog();
            },
          ),
        ],
      ),
      body: Consumer<LogProvider>(
        builder: (context, logProvider, child) {
          List logs = logProvider.logs;

          if (_selectedFilter != 'All') {
            logs = logs.where((log) => log.type == _selectedFilter).toList();
          }

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No logs yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            reverse: true,
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[logs.length - 1 - index];
              return _buildLogCard(log);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogCard(log) {
    Color color;
    IconData icon;

    switch (log.type) {
      case 'REQUEST':
        color = Colors.blue;
        icon = Icons.http;
        break;
      case 'NOTIFICATION':
        color = Colors.green;
        icon = Icons.notifications;
        break;
      case 'ERROR':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'INFO':
        color = Colors.grey;
        icon = Icons.info;
        break;
      case 'WARNING':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        color = Colors.grey;
        icon = Icons.notes;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(log.message, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          _formatTimestamp(log.timestamp),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Chip(
          label: Text(log.type, style: const TextStyle(fontSize: 10)),
          backgroundColor: color.withOpacity(0.1),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showClearLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<LogProvider>().clearLogs();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logs cleared')));
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
