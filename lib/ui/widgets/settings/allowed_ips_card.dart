import 'package:flutter/material.dart';

class AllowedIpsCard extends StatelessWidget {
  const AllowedIpsCard({
    required this.ipController,
    required this.allowedIps,
    required this.onAddIp,
    required this.onRemoveIp,
    required this.onShowInfo,
    super.key,
  });

  final TextEditingController ipController;
  final List<String> allowedIps;
  final VoidCallback onAddIp;
  final ValueChanged<String> onRemoveIp;
  final VoidCallback onShowInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Allowed IPs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: onShowInfo,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ipController,
                    decoration: const InputDecoration(
                      labelText: 'Add IP Address',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 127.0.0.1 or 192.168.1.0/24',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onAddIp,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (allowedIps.isEmpty)
              const Text(
                'No IPs added. All IPs will be allowed.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allowedIps.map((ip) {
                  return Chip(
                    label: Text(ip),
                    onDeleted: () => onRemoveIp(ip),
                    deleteIcon: const Icon(Icons.close),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
