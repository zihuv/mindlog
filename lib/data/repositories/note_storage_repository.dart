import 'package:mindlog/data/models/note.dart';

abstract class NoteStorageRepository {
  Future<void> initialize();
  Future<List<Note>> getAllNotes();
  Future<List<Note>> getAllNotesForSync();
  Future<Note?> getNoteById(String id);
  Future<void> saveNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<List<Note>> searchNotes(String query);
  Future<List<Note>> getNotesByNotebookId(String notebookId);
  Future<List<Note>> getNotesByDate(DateTime date);
  Future<List<Note>> getNotesByNotebookIdAndDate(
    String notebookId,
    DateTime date,
  );
  // 新增方法：获取指定笔记本和日期的所有笔记（包括已删除的）
  Future<List<Note>> getAllNotesByNotebookIdAndDate(
    String notebookId,
    DateTime date,
  );
  Future<List<String>> getAllTags();
  Future<void> close();
}
