import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'settings/backup_screen.dart';
import 'settings/webdav_settings_screen.dart';
import 'settings/image_compression_settings_screen.dart';

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
            Text('General', style: Theme.of(context).textTheme.titleLarge),
            const Gap(16),
            _buildBackupCard(context),
            const Gap(16),
            _buildWebDAVCard(context),
            const Gap(16),
            _buildImageCompressionCard(context),
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

  Widget _buildWebDAVCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.cloud_sync),
        title: const Text('WebDAV Sync'),
        subtitle: const Text('Sync your notes with WebDAV'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Get.to(() => const WebDAVSettingsScreen());
        },
      ),
    );
  }

  Widget _buildImageCompressionCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.compress),
        title: const Text('Image Compression'),
        subtitle: const Text('Manage image quality and compression'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Get.to(() => const ImageCompressionSettingsScreen());
        },
      ),
    );
  }
}
