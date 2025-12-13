import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageCompressionSettingsScreen extends StatefulWidget {
  const ImageCompressionSettingsScreen({super.key});

  @override
  State<ImageCompressionSettingsScreen> createState() =>
      _ImageCompressionSettingsScreenState();
}

class _ImageCompressionSettingsScreenState
    extends State<ImageCompressionSettingsScreen> {
  String _selectedQuality = 'standard'; // Default quality level
  bool _compressionEnabled = true; // Default: compression enabled

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedQuality =
          prefs.getString('image_compression_quality') ?? 'standard';
      _compressionEnabled = prefs.getBool('image_compression_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('image_compression_quality', _selectedQuality);
    await prefs.setBool('image_compression_enabled', _compressionEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Compression'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compression Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(16),

              // Toggle for enabling/disabling compression
              Card(
                child: SwitchListTile(
                  title: const Text('Enable Image Compression'),
                  value: _compressionEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _compressionEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
              const Gap(16),

              // Quality selection options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quality Level',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Gap(12),
                      _buildQualityOption(
                        'Low Quality',
                        'Smaller file size, lower image quality',
                        'low',
                      ),
                      _buildQualityOption(
                        'Standard (Recommended)',
                        'Good balance between quality and file size',
                        'standard',
                      ),
                      _buildQualityOption(
                        'High Quality',
                        'Better image quality, larger file size',
                        'high',
                      ),
                      _buildQualityOption(
                        'Original Quality',
                        'No compression applied',
                        'original',
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(16),

              // Information card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Image Compression',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Gap(8),
                      const Text(
                        'Enabling image compression will reduce the file size of images added to your notes. '
                        'This can save storage space and improve sync performance. The quality setting controls '
                        'the trade-off between file size and image quality.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualityOption(String title, String subtitle, String value) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: _selectedQuality,
      onChanged: _compressionEnabled
          ? (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedQuality = newValue;
                });
                _saveSettings();
              }
            }
          : null, // Disable selection if compression is disabled
    );
  }
}
