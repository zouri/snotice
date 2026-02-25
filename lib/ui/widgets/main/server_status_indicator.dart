import 'package:flutter/material.dart';

class ServerStatusIndicator extends StatelessWidget {
  const ServerStatusIndicator({
    required this.isServerRunning,
    required this.port,
    required this.onTap,
    super.key,
  });

  final bool isServerRunning;
  final int port;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = isServerRunning
        ? colorScheme.tertiary
        : colorScheme.error;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isServerRunning ? Icons.cloud_done : Icons.cloud_off,
              color: statusColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(':$port', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
