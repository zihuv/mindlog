import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindlog/features/journal/domain/entities/journal_entry.dart';
import 'package:mindlog/core/storage/interfaces/storage_repository.dart';

class SimpleStorageRepository implements StorageRepository {
  static const String _key = 'journal_entries';
  SharedPreferences? _prefs;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<JournalEntry>> getAllJournalEntries() async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final jsonString = _prefs!.getString(_key) ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((json) => _fromJson(json)).toList();
  }

  @override
  Future<JournalEntry?> getJournalEntryById(int id) async {
    final allEntries = await getAllJournalEntries();
    final entry = allEntries.firstWhere(
      (entry) => entry.id == id,
      orElse: () =>
          JournalEntry(id: 0, content: '', dateTime: DateTime.now(), mood: ''),
    );
    return entry.id == 0
        ? null
        : entry; // Return null if default entry was returned
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesByDate(DateTime date) async {
    final allEntries = await getAllJournalEntries();

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day + 1);

    return allEntries
        .where(
          (entry) =>
              entry.dateTime.isAfter(startOfDay) &&
              entry.dateTime.isBefore(endOfDay),
        )
        .toList();
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final allEntries = await getAllJournalEntries();

    // Check if entry already exists and update it, otherwise add new
    final existingIndex = allEntries.indexWhere((e) => e.id == entry.id);
    if (existingIndex != -1) {
      allEntries[existingIndex] = entry;
    } else {
      allEntries.add(entry);
    }

    final jsonString = json.encode(
      allEntries.map((entry) => _toJson(entry)).toList(),
    );
    await _prefs!.setString(_key, jsonString);
  }

  @override
  Future<void> updateJournalEntry(JournalEntry entry) async {
    await saveJournalEntry(entry);
  }

  @override
  Future<void> deleteJournalEntry(int id) async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final allEntries = await getAllJournalEntries();
    allEntries.removeWhere((entry) => entry.id == id);

    final jsonString = json.encode(
      allEntries.map((entry) => _toJson(entry)).toList(),
    );
    await _prefs!.setString(_key, jsonString);
  }

  @override
  Future<void> close() async {
    // No specific close action needed for shared preferences
  }

  Map<String, dynamic> _toJson(JournalEntry entry) {
    return {
      'id': entry.id,
      'content': entry.content,
      'dateTime': entry.dateTime.toIso8601String(),
      'mood': entry.mood,
    };
  }

  JournalEntry _fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      dateTime: json.containsKey('dateTime')
          ? DateTime.parse(json['dateTime'])
          : DateTime.fromMillisecondsSinceEpoch(
              json['date'] ?? DateTime.now().millisecondsSinceEpoch,
            ),
      mood: json['mood'] ?? '',
    );
  }
}
