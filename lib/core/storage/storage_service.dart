import 'package:think_tract_flutter/core/storage/interfaces/storage_repository.dart';
import 'package:think_tract_flutter/core/storage/simple_storage_repository.dart';

class StorageService {
  static StorageRepository? _instance;

  static StorageRepository get instance {
    if (_instance == null) {
      throw Exception('StorageService has not been initialized');
    }
    return _instance!;
  }

  static Future<void> initialize() async {
    _instance = SimpleStorageRepository();
    await _instance!.initialize();
  }

  static void dispose() {
    _instance?.close();
    _instance = null;
  }
}
