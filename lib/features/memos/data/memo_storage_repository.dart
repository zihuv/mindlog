import 'package:mindlog/features/memos/domain/entities/memo.dart';

abstract class MemoStorageRepository {
  Future<void> initialize();
  Future<List<Memo>> getAllMemos();
  Future<Memo?> getMemoById(String id);
  Future<void> saveMemo(Memo memo);
  Future<void> updateMemo(Memo memo);
  Future<void> deleteMemo(String id);
  Future<List<Memo>> searchMemos(String query);
  Future<List<String>> getAllTags();
  Future<void> close();
}
