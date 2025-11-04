import 'package:flutter/material.dart';
import 'package:think_tract_flutter/core/storage/storage_service.dart';
import 'package:think_tract_flutter/core/storage/webdav_config.dart';

class WebDAVSettingsPage extends StatefulWidget {
  const WebDAVSettingsPage({super.key});

  @override
  State<WebDAVSettingsPage> createState() => _WebDAVSettingsPageState();
}

class _WebDAVSettingsPageState extends State<WebDAVSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _remotePathController = TextEditingController(text: '/think_track/');

  bool _isWebDAVEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() async {
    final config = StorageService.webDAVConfig;
    if (config != null) {
      _serverUrlController.text = config.serverUrl;
      _usernameController.text = config.username;
      _passwordController.text = config.password;
      _remotePathController.text = config.remotePath;
      setState(() {
        _isWebDAVEnabled = true;
      });
    }
  }

  Future<void> _saveWebDAVConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = WebDAVConfig(
        serverUrl: _serverUrlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        remotePath: _remotePathController.text.trim(),
      );

      bool isConnected = await StorageService.testWebDAVConnection(config);
      if (isConnected) {
        await StorageService.switchToWebDAV(config);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WebDAV configuration saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isWebDAVEnabled = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to connect to WebDAV server. Please check your credentials.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving WebDAV config: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _disableWebDAV() async {
    await StorageService.switchToLocal();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WebDAV disabled. Using local storage only.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _isWebDAVEnabled = false;
        _serverUrlController.clear();
        _usernameController.clear();
        _passwordController.clear();
        _remotePathController.text = '/think_track/';
      });
    }
  }

  Future<void> _testWebDAVConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = WebDAVConfig(
        serverUrl: _serverUrlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        remotePath: _remotePathController.text.trim(),
      );

      bool isConnected = await StorageService.testWebDAVConnection(config);
      if (isConnected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WebDAV connection successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to connect to WebDAV server. Please check your credentials.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error testing WebDAV connection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebDAV Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Configure WebDAV for cross-platform synchronization',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _serverUrlController,
                decoration: const InputDecoration(
                  labelText: 'WebDAV Server URL',
                  hintText: 'https://dav.example.com',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the server URL';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'URL must start with http:// or https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remotePathController,
                decoration: const InputDecoration(
                  labelText: 'Remote Path',
                  hintText: '/think_track/',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a remote path';
                  }
                  if (!value.startsWith('/')) {
                    return 'Path must start with /';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isWebDAVEnabled)
                const Text(
                  'WebDAV synchronization is currently enabled',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              else
                const Text(
                  'WebDAV synchronization is currently disabled',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else Column(
                children: [
                  ElevatedButton(
                    onPressed: _saveWebDAVConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save WebDAV Configuration'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _testWebDAVConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test WebDAV Connection'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isWebDAVEnabled)
                ElevatedButton(
                  onPressed: _disableWebDAV,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Disable WebDAV Sync'),
                ),
              const SizedBox(height: 20),
              const Text(
                'For Nutstore (坚果云), use the following settings:\n'
                'Server URL: https://dav.jianguoyun.com/dav/\n'
                'Username: Your full email address\n'
                'Password: Your Nutstore password or app password',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _remotePathController.dispose();
    super.dispose();
  }
}