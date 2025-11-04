import 'package:flutter/material.dart';
import 'webdav_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_sync),
                title: const Text('WebDAV Sync'),
                subtitle: const Text('Configure cross-platform data synchronization'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WebDAVSettingsPage()),
                  );
                },
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info),
                title: const Text('About'),
                subtitle: Text('Think Track v1.0.0'),
              ),
            ),
            // Add more settings options as needed
          ],
        ),
      ),
    );
  }
}