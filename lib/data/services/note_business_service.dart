import 'package:mindlog/data/services/note_service.dart';
import 'package:mindlog/data/models/note.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class NoteBusinessService {
  static const Uuid _uuid = Uuid();

  Future<void> init() async {
    final service = Get.find<NoteService>();
    // Ensure the service is initialized before using it
    await service.init();
  }

  // Get all notes including deleted ones for sync purposes
  Future<List<Note>> getAllNotesForSync() async {
    return await Get.find<NoteService>().getAllNotesForSync();
  }

  // Create a new note
  Future<String> createNote({
    required String content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    String? notebookId,
    DateTime? createTime,
  }) async {
    final noteId = _uuid.v7();
    final now = createTime ?? DateTime.now();

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
    DateTime? updateTime,
  }) async {
    // Get the existing note
    final existingNote = await getNoteById(id);
    if (existingNote == null) {
      throw Exception('Note with id $id does not exist');
    }

    // Create updated note with new values or keep existing ones
    final updatedNote = existingNote.copyWith(
      content: content ?? existingNote.content,
      images: imageName ?? existingNote.images,
      audios: audioName ?? existingNote.audios,
      videos: videoName ?? existingNote.videos,
      notebookId: notebookId ?? existingNote.notebookId,
      updateTime: updateTime ?? DateTime.now(),
    );

    await Get.find<NoteService>().updateNote(updatedNote);
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await Get.find<NoteService>().deleteNote(id);
  }

  // Search notes
  Future<List<Note>> searchNotes(String query) async {
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

  // Get notes by notebook ID and date
  Future<List<Note>> getNotesByNotebookIdAndDate(
    String notebookId,
    DateTime date,
  ) async {
    return await Get.find<NoteService>().getNotesByNotebookIdAndDate(
      notebookId,
      date,
    );
  }

  // 获取指定笔记本和日期的所有笔记（包括已删除的）
  Future<List<Note>> getAllNotesByNotebookIdAndDate(
    String notebookId,
    DateTime date,
  ) async {
    return await Get.find<NoteService>().getAllNotesByNotebookIdAndDate(
      notebookId,
      date,
    );
  }

  // Get all tags
  Future<List<String>> getAllTags() async {
    return await Get.find<NoteService>().getAllTags();
  }

  // Close the service
  Future<void> close() async {
    await Get.find<NoteService>().close();
  }
}
