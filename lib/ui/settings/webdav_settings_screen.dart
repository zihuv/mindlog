import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindlog/utils/webdav_util.dart';

class WebDAVSettingsScreen extends StatefulWidget {
  const WebDAVSettingsScreen({super.key});

  @override
  State<WebDAVSettingsScreen> createState() => _WebDAVSettingsScreenState();
}

class _WebDAVSettingsScreenState extends State<WebDAVSettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _folderController = TextEditingController(
    text: 'mindlog',
  );

  bool _isLoading = false;
  bool _isConnected = false;
  String _connectionStatus = 'Not tested';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlController.text = prefs.getString('webdav_url') ?? '';
      _usernameController.text = prefs.getString('webdav_username') ?? '';
      _passwordController.text = prefs.getString('webdav_password') ?? '';
      _folderController.text = prefs.getString('webdav_folder') ?? 'mindlog';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('webdav_url', _urlController.text);
    await prefs.setString('webdav_username', _usernameController.text);
    await prefs.setString('webdav_password', _passwordController.text);
    await prefs.setString('webdav_folder', _folderController.text);
  }

  Future<void> _testConnection() async {
    if (_urlController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing...';
    });

    try {
      WebDAVConfig config = WebDAVConfig(
        url: _urlController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        folderName: _folderController.text,
      );

      WebDAVUtil webdavUtil = WebDAVUtil();
      await webdavUtil.init(config);

      bool connected = await webdavUtil.testConnection();

      setState(() {
        _isConnected = connected;
        _connectionStatus = connected
            ? 'Connected successfully'
            : 'Connection failed';
      });

      if (connected) {
        _showSuccess('Connection successful!');
        await _saveSettings();
      } else {
        _showError('Connection failed. Please check your settings.');
      }

      webdavUtil.dispose();
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Connection failed: ${e.toString()}';
      });
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performSync() async {
    if (_urlController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Please configure your WebDAV settings first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      WebDAVConfig config = WebDAVConfig(
        url: _urlController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        folderName: _folderController.text,
      );

      WebDAVUtil webdavUtil = WebDAVUtil();
      await webdavUtil.init(config);

      await webdavUtil.sync();

      _showSuccess('Sync completed successfully!');
      await _saveSettings();

      webdavUtil.dispose();
    } catch (e) {
      _showError('Sync failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccess(String message) {
    // Using ScaffoldMessenger to show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    // Using ScaffoldMessenger to show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebDAV Sync'),
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
                'WebDAV Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _urlController,
                label: 'WebDAV URL',
                hint: 'https://example.com/remote.php/webdav/',
                prefixIcon: Icons.link,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Your WebDAV username',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Your WebDAV password',
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _folderController,
                label: 'Folder Name',
                hint: 'Folder name on WebDAV server (default: mindlog)',
                prefixIcon: Icons.folder,
              ),
              const SizedBox(height: 24),
              Text(
                'Connection Status: $_connectionStatus',
                style: TextStyle(
                  color: _isConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test Connection'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _performSync,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sync Now'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Enter your WebDAV server details above\n'
                        '2. Click "Test Connection" to verify your settings\n'
                        '3. Click "Sync Now" to start the synchronization\n\n'
                        'Your notes will be stored in the specified folder under the following structure:\n'
                        '/[folder_name]/\n'
                        '├── Note/\n'
                        '│   └── [year]/\n'
                        '│       └── [note_id].json\n'
                        '├── Asset/\n'
                        '│   └── Image/\n'
                        '│       └── [year]/\n'
                        '│           └── [note_id]/\n'
                        '│               └── [image_name]\n'
                        '└── sync.json',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _folderController.dispose();
    super.dispose();
  }
}
