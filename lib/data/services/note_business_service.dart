import 'package:mindlog/features/notes/data/note_service.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:uuid/uuid.dart';

class NoteBusinessService {
  static const Uuid _uuid = Uuid();

  Future<void> init() async {
    await NoteService.instance.init();
  }

  // Create a new note
  Future<String> createNote({
    required String content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    String? notebookId,
  }) async {
    final noteId = _uuid.v7();
    final now = DateTime.now();

    // Create a new note with the generated UUID
    final note = Note(
      id: noteId,
      content: content,
      createTime: now,
      updateTime: now,
      notebookId: notebookId,
      images: imageName ?? [],
      videos: videoName ?? [],
      audios: audioName ?? [],
    );

    await NoteService.instance.saveNote(note);
    return noteId;
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    return await NoteService.instance.getAllNotes();
  }

  // Get a note by ID
  Future<Note?> getNoteById(String id) async {
    return await NoteService.instance.getNoteById(id);
  }

  // Update a note
  Future<void> updateNote({
    required String id,
    String? content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    String? notebookId,
  }) async {
    final existingNote = await NoteService.instance.getNoteById(id);
    if (existingNote == null) {
      throw Exception('Note with id $id does not exist');
    }

    final updatedNote = Note(
      id: id,
      content: content ?? existingNote.content,
      createTime: existingNote.createTime,
      updateTime: DateTime.now(),
      notebookId: notebookId ?? existingNote.notebookId,
      images: imageName ?? existingNote.images,
      videos: videoName ?? existingNote.videos,
      audios: audioName ?? existingNote.audios,
    );

    await NoteService.instance.updateNote(updatedNote);
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await NoteService.instance.deleteNote(id);
  }

  // Search notes by content
  Future<List<Note>> searchNotes(String query) async {
    if (query.trim().isEmpty) {
      return await getAllNotes();
    }
    return await NoteService.instance.searchNotes(query);
  }

  // Get notes by notebook ID
  Future<List<Note>> getNotesByNotebookId(String notebookId) async {
    return await NoteService.instance.getNotesByNotebookId(notebookId);
  }

  // Get all unique tags
  Future<List<String>> getAllTags() async {
    return await NoteService.instance.getAllTags();
  }

  // Close the connection
  Future<void> close() async {
    // Note service doesn't require explicit closing
  }
}
