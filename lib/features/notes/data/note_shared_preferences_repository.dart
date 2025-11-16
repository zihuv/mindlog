import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/data/note_storage_repository.dart';
import 'package:uuid/uuid.dart';

class NoteSharedPreferencesRepository implements NoteStorageRepository {
  static const String _key = 'notes';
  SharedPreferences? _prefs;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<Note>> getAllNotes() async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final jsonString = _prefs!.getString(_key) ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((json) => Note.fromJson(json)).toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final allNotes = await getAllNotes();
    final note = allNotes.firstWhere(
      (note) => note.id == id,
      orElse: () => Note(
        id: '',
        content: '',
        createdAt: DateTime.now(),
        isPinned: false,
        visibility: 'PRIVATE',
      ),
    );
    return note.id.isEmpty
        ? null
        : note; // Return null if default note was returned
  }

  @override
  Future<void> saveNote(Note note) async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final allNotes = await getAllNotes();

    // Generate a UUID if the note doesn't have an ID yet
    final noteToSave = note.id.isEmpty ? note.copyWith(id: Uuid().v7()) : note;

    // Check if note already exists and update it, otherwise add new
    final existingIndex = allNotes.indexWhere((n) => n.id == noteToSave.id);
    if (existingIndex != -1) {
      allNotes[existingIndex] = noteToSave;
    } else {
      allNotes.add(noteToSave);
    }

    final jsonString = json.encode(
      allNotes.map((note) => note.toJson()).toList(),
    );
    await _prefs!.setString(_key, jsonString);
  }

  @override
  Future<void> updateNote(Note note) async {
    await saveNote(note);
  }

  @override
  Future<void> deleteNote(String id) async {
    if (_prefs == null) throw Exception('Storage not initialized');

    final allNotes = await getAllNotes();
    allNotes.removeWhere((note) => note.id == id);

    final jsonString = json.encode(
      allNotes.map((note) => note.toJson()).toList(),
    );
    await _prefs!.setString(_key, jsonString);
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    final allNotes = await getAllNotes();
    if (query.isEmpty) return allNotes;

    return allNotes
        .where(
          (note) =>
              note.content.toLowerCase().contains(query.toLowerCase()) ||
              note.tags.any(
                (tag) => tag.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
  }

  @override
  Future<List<Note>> getNotesByNotebookId(String notebookId) async {
    final allNotes = await getAllNotes();
    return allNotes
        .where((note) => note.notebookId == notebookId)
        .toList();
  }

  @override
  Future<List<String>> getAllTags() async {
    final allNotes = await getAllNotes();
    final allTags = <String>{};
    for (final note in allNotes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList();
  }

  @override
  Future<void> close() async {
    // No specific close action needed for shared preferences
  }
}
