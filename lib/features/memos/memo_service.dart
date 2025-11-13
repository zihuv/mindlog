import 'package:mindlog/features/memos/data/memo_storage_repository.dart';
import 'package:mindlog/features/memos/data/memo_shared_preferences_repository.dart';
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
    // Ensure previous repository is closed
    if (_repository != null) {
      await _repository!.close();
    }

    // Create local storage repository
    _repository = MemoSharedPreferencesRepository();
    await _repository!.initialize();
  }

  // Proxy all MemoStorageRepository methods to current repository
  Future<void> initialize() => repository.initialize();
  Future<List<Memo>> getAllMemos() => repository.getAllMemos();
  Future<Memo?> getMemoById(int id) => repository.getMemoById(id);
  Future<void> saveMemo(Memo memo) => repository.saveMemo(memo);
  Future<void> updateMemo(Memo memo) => repository.updateMemo(memo);
  Future<void> deleteMemo(int id) => repository.deleteMemo(id);
  Future<List<Memo>> searchMemos(String query) => repository.searchMemos(query);
  Future<List<String>> getAllTags() => repository.getAllTags();
  Future<void> close() => repository.close();
}
