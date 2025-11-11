import 'package:flutter/material.dart';

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
            const Card(
              child: ListTile(
                leading: Icon(Icons.info),
                title: const Text('About'),
                subtitle: Text('MindLog v1.0.0'),
              ),
            ),
            // Add more settings options as needed
          ],
        ),
      ),
    );
  }
}
