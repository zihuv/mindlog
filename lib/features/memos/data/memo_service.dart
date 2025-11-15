import 'package:mindlog/features/memos/data/memo_storage_repository.dart';
import 'package:mindlog/features/memos/data/memo_database_repository.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';

class MemoService {
  MemoStorageRepository? _repository;

  static MemoService? _instance;
  static MemoService get instance {
    _instance ??= MemoService();
    return _instance!;
  }

  MemoStorageRepository get repository {
    if (_repository == null) {
      throw Exception('MemoService not initialized. Call init() first.');
    }
    return _repository!;
  }

  Future<void> init() async {
    await _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    // Don't close the repository here since it uses shared database
    if (_repository == null) {
      // Create database repository for UUID support
      _repository = MemoDatabaseRepository();
      await _repository!.initialize();
    }
  }

  // Proxy all MemoStorageRepository methods to current repository
  Future<void> initialize() => repository.initialize();
  Future<List<Memo>> getAllMemos() => repository.getAllMemos();
  Future<Memo?> getMemoById(String id) => repository.getMemoById(id);
  Future<void> saveMemo(Memo memo) => repository.saveMemo(memo);
  Future<void> updateMemo(Memo memo) => repository.updateMemo(memo);
  Future<void> deleteMemo(String id) => repository.deleteMemo(id);
  Future<List<Memo>> searchMemos(String query) => repository.searchMemos(query);
  Future<List<String>> getAllTags() => repository.getAllTags();
  Future<void> close() async {
    // Don't close the repository since it uses shared database
    // The shared database will be closed separately
  }
}
