import 'package:think_tract_flutter/core/storage/interfaces/storage_repository.dart';
import 'package:think_tract_flutter/core/storage/simple_storage_repository.dart';
import 'package:think_tract_flutter/core/storage/webdav_storage_repository.dart';
import 'package:think_tract_flutter/core/storage/webdav_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class StorageService {
  static StorageRepository? _instance;
  static StorageRepository? _fallbackInstance; // Fallback to local storage
  static bool _useWebDAV = false;
  static WebDAVConfig? _webDAVConfig;

  static StorageRepository get instance {
    if (_instance == null) {
      throw Exception('StorageService has not been initialized');
    }
    return _instance!;
  }

  static bool get isUsingWebDAV => _useWebDAV;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if WebDAV is configured
    final serverUrl = prefs.getString('webdav_server_url');
    final username = prefs.getString('webdav_username');
    final password = prefs.getString('webdav_password');
    
    if (serverUrl != null && username != null && password != null) {
      // Initialize WebDAV storage
      _webDAVConfig = WebDAVConfig(
        serverUrl: serverUrl,
        username: username,
        password: password,
        remotePath: prefs.getString('webdav_remote_path') ?? '/think_track/',
      );
      
      try {
        _instance = WebDAVStorageRepository(
          serverUrl: serverUrl,
          username: username,
          password: password,
          remotePath: prefs.getString('webdav_remote_path') ?? '/think_track/',
        );
        await _instance!.initialize();
        
        // Set up fallback to local storage
        _fallbackInstance = SimpleStorageRepository();
        await _fallbackInstance!.initialize();
        
        _useWebDAV = true;
      } catch (e) {
        print('Failed to initialize WebDAV storage: $e, falling back to local storage');
        _instance = SimpleStorageRepository();
        await _instance!.initialize();
        _useWebDAV = false;
      }
    } else {
      // Use local storage only
      _instance = SimpleStorageRepository();
      await _instance!.initialize();
      _useWebDAV = false;
    }
  }

  static Future<void> switchToWebDAV(WebDAVConfig config) async {
    try {
      final webdavStorage = WebDAVStorageRepository(
        serverUrl: config.serverUrl,
        username: config.username,
        password: config.password,
        remotePath: config.remotePath,
      );
      await webdavStorage.initialize();
      
      // Set up fallback to local storage
      _fallbackInstance = SimpleStorageRepository();
      await _fallbackInstance!.initialize();
      
      // Save config to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('webdav_server_url', config.serverUrl);
      await prefs.setString('webdav_username', config.username);
      await prefs.setString('webdav_password', config.password);
      await prefs.setString('webdav_remote_path', config.remotePath);
      
      // Switch to WebDAV storage
      _instance = webdavStorage;
      _webDAVConfig = config;
      _useWebDAV = true;
    } catch (e) {
      print('Failed to switch to WebDAV: $e');
      rethrow;
    }
  }

  static Future<void> switchToLocal() async {
    final localStorage = SimpleStorageRepository();
    await localStorage.initialize();
    
    // Clear WebDAV config from preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('webdav_server_url');
    await prefs.remove('webdav_username');
    await prefs.remove('webdav_password');
    await prefs.remove('webdav_remote_path');
    
    _instance = localStorage;
    _webDAVConfig = null;
    _useWebDAV = false;
  }

  static void dispose() {
    _instance?.close();
    _fallbackInstance?.close();
    _instance = null;
    _fallbackInstance = null;
  }
  
  static WebDAVConfig? get webDAVConfig => _webDAVConfig;
  
  static Future<bool> testWebDAVConnection(WebDAVConfig config) async {
    try {
      final client = webdav.newClient(
        config.serverUrl,
        user: config.username,
        password: config.password,
        debug: false,
      );
      
      // Try to create or access the remote path
      await client.mkdir(config.remotePath);
      return true;
    } catch (e) {
      print('WebDAV connection test failed: $e');
      return false;
    }
  }
}
