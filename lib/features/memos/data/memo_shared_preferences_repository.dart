import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:mindlog/features/memos/data/memo_storage_repository.dart';

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
  Future<Memo?> getMemoById(int id) async {
    final allMemos = await getAllMemos();
    final memo = allMemos.firstWhere(
      (memo) => memo.id == id,
      orElse: () => Memo(
        id: 0,
        content: '',
        createdAt: DateTime.now(),
        isPinned: false,
        visibility: 'PRIVATE',
      ),
    );
    return memo.id == 0
        ? null
        : memo; // Return null if default memo was returned
  }

  @override
  Future<void> saveMemo(Memo memo) async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final allMemos = await getAllMemos();

    // Check if memo already exists and update it, otherwise add new
    final existingIndex = allMemos.indexWhere((m) => m.id == memo.id);
    if (existingIndex != -1) {
      allMemos[existingIndex] = memo;
    } else {
      allMemos.add(memo);
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
  Future<void> deleteMemo(int id) async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final allMemos = await getAllMemos();
    allMemos.removeWhere((memo) => memo.id == id);

    final jsonString = json.encode(
      allMemos.map((memo) => memo.toJson()).toList(),
    );
    await _prefs!.setString(_key, jsonString);
  }

  @override
  Future<void> close() async {
    // No specific close action needed for shared preferences
  }
}
