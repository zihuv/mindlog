import 'package:mindlog/features/notes/data/note_service.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class NoteBusinessService {
  static const Uuid _uuid = Uuid();

  Future<void> init() async {
    final service = Get.find<NoteService>();
    // Ensure the service is initialized before using it
    await service.init();
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

    await Get.find<NoteService>().saveNote(note);
    return noteId;
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    return await Get.find<NoteService>().getAllNotes();
  }

  // Get all notes including deleted ones for sync purposes
  Future<List<Note>> getAllNotesForSync() async {
    return await Get.find<NoteService>().getAllNotesForSync();
  }

  // Get a note by ID
  Future<Note?> getNoteById(String id) async {
    return await Get.find<NoteService>().getNoteById(id);
  }

  // Update a note
  Future<void> updateNote({
    required String id,
    String? content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    String? notebookId,
    DateTime? updateTime, // Allow specifying updateTime from cloud
  }) async {
    final existingNote = await Get.find<NoteService>().getNoteById(id);
    if (existingNote == null) {
      throw Exception('Note with id $id does not exist');
    }

    final updatedNote = Note(
      id: id,
      content: content ?? existingNote.content,
      createTime: existingNote.createTime,
      // Keep existing updateTime unless explicitly provided (to maintain cloud data consistency)
      updateTime: updateTime ?? existingNote.updateTime,
      notebookId: notebookId ?? existingNote.notebookId,
      images: imageName ?? existingNote.images,
      videos: videoName ?? existingNote.videos,
      audios: audioName ?? existingNote.audios,
    );

    await Get.find<NoteService>().updateNote(updatedNote);
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await Get.find<NoteService>().deleteNote(id);
  }

  // Search notes by content
  Future<List<Note>> searchNotes(String query) async {
    if (query.trim().isEmpty) {
      return await getAllNotes();
    }
    return await Get.find<NoteService>().searchNotes(query);
  }

  // Get notes by notebook ID
  Future<List<Note>> getNotesByNotebookId(String notebookId) async {
    return await Get.find<NoteService>().getNotesByNotebookId(notebookId);
  }

  // Get notes by date
  Future<List<Note>> getNotesByDate(DateTime date) async {
    return await Get.find<NoteService>().getNotesByDate(date);
  }

  // Get all unique tags
  Future<List<String>> getAllTags() async {
    return await Get.find<NoteService>().getAllTags();
  }

  // Close the connection
  Future<void> close() async {
    // Note service doesn't require explicit closing
  }
}