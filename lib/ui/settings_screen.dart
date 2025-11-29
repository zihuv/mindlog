import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings/backup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildBackupCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.backup),
        title: const Text('Backup'),
        subtitle: const Text('Export or import your data'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Get.to(() => BackupScreen());
        },
      ),
    );
  }
}
