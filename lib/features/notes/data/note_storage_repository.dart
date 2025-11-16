import 'package:mindlog/features/notes/domain/entities/note.dart';

abstract class NoteStorageRepository {
  Future<void> initialize();
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteById(String id);
  Future<void> saveNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<List<Note>> searchNotes(String query);
  Future<List<Note>> getNotesByNotebookId(String notebookId);
  Future<List<String>> getAllTags();
  Future<void> close();
}
