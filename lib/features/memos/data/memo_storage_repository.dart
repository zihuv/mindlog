import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindlog/features/memos/domain/entities/memo.dart';

abstract class MemoStorageRepository {
  Future<void> initialize();
  Future<List<Memo>> getAllMemos();
  Future<Memo?> getMemoById(int id);
  Future<void> saveMemo(Memo memo);
  Future<void> updateMemo(Memo memo);
  Future<void> deleteMemo(int id);
  Future<void> close();
}
