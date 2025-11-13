import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:mindlog/features/memos/data/memo_storage_repository.dart';
import 'package:uuid/uuid.dart';

class MemoSharedPreferencesRepository implements MemoStorageRepository {
  static const String _key = 'memos';
  SharedPreferences? _prefs;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<Memo>> getAllMemos() async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final jsonString = _prefs!.getString(_key) ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((json) => Memo.fromJson(json)).toList();
  }

  @override
  Future<Memo?> getMemoById(String id) async {
    final allMemos = await getAllMemos();
    final memo = allMemos.firstWhere(
      (memo) => memo.id == id,
      orElse: () => Memo(
        id: '',
        content: '',
        createdAt: DateTime.now(),
        isPinned: false,
        visibility: 'PRIVATE',
      ),
    );
    return memo.id.isEmpty
        ? null
        : memo; // Return null if default memo was returned
  }

  @override
  Future<void> saveMemo(Memo memo) async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final allMemos = await getAllMemos();

    // Generate a UUID if the memo doesn't have an ID yet
    final memoToSave = memo.id.isEmpty ? memo.copyWith(id: Uuid().v7()) : memo;

    // Check if memo already exists and update it, otherwise add new
    final existingIndex = allMemos.indexWhere((m) => m.id == memoToSave.id);
    if (existingIndex != -1) {
      allMemos[existingIndex] = memoToSave;
    } else {
      allMemos.add(memoToSave);
    }

    final jsonString = json.encode(
      allMemos.map((memo) => memo.toJson()).toList(),
    );
    await _prefs!.setString(_key, jsonString);
  }

  @override
  Future<void> updateMemo(Memo memo) async {
    await saveMemo(memo);
  }

  @override
  Future<void> deleteMemo(String id) async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final allMemos = await getAllMemos();
    allMemos.removeWhere((memo) => memo.id == id);

    final jsonString = json.encode(
      allMemos.map((memo) => memo.toJson()).toList(),
    );
    await _prefs!.setString(_key, jsonString);
  }

  @override
  Future<List<Memo>> searchMemos(String query) async {
    final allMemos = await getAllMemos();
    if (query.isEmpty) return allMemos;

    return allMemos
        .where(
          (memo) =>
              memo.content.toLowerCase().contains(query.toLowerCase()) ||
              memo.tags.any(
                (tag) => tag.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
  }

  @override
  Future<List<String>> getAllTags() async {
    final allMemos = await getAllMemos();
    final allTags = <String>{};
    for (final memo in allMemos) {
      allTags.addAll(memo.tags);
    }
    return allTags.toList();
  }

  @override
  Future<void> close() async {
    // No specific close action needed for shared preferences
  }
}
