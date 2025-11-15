import 'package:mindlog/features/memos/data/memo_service.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:uuid/uuid.dart';

class NoteService {
  static const Uuid _uuid = Uuid();

  Future<void> init() async {
    await MemoService.instance.init();
  }

  // Create a new note
  Future<String> createNote({
    required String content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    List<String>? tags,
    Map<int, bool>? checklistStates,
    String? notebookId,
  }) async {
    final noteId = _uuid.v7();
    final now = DateTime.now();

    // Create a new memo with the generated UUID
    final memo = Memo(
      id: noteId,
      content: content,
      createdAt: now,
      updatedAt: now,
      notebookId: notebookId,
      tags: tags ?? [],
      images: imageName ?? [],
      videos: videoName ?? [],
      audios: audioName ?? [],
      checklistStates: checklistStates ?? const {},
    );

    await MemoService.instance.saveMemo(memo);
    return noteId;
  }

  // Get all notes
  Future<List<Memo>> getAllNotes() async {
    return await MemoService.instance.getAllMemos();
  }

  // Get a note by ID
  Future<Memo?> getNoteById(String id) async {
    return await MemoService.instance.getMemoById(id);
  }

  // Update a note
  Future<void> updateNote({
    required String id,
    String? content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    List<String>? tags,
    Map<int, bool>? checklistStates,
    String? notebookId,
  }) async {
    final existingNote = await MemoService.instance.getMemoById(id);
    if (existingNote == null) {
      throw Exception('Note with id $id does not exist');
    }

    final updatedNote = Memo(
      id: id,
      content: content ?? existingNote.content,
      createdAt: existingNote.createdAt,
      updatedAt: DateTime.now(),
      notebookId: notebookId ?? existingNote.notebookId,
      tags: tags ?? existingNote.tags,
      images: imageName ?? existingNote.images,
      videos: videoName ?? existingNote.videos,
      audios: audioName ?? existingNote.audios,
      checklistStates: checklistStates ?? existingNote.checklistStates,
    );

    await MemoService.instance.updateMemo(updatedNote);
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await MemoService.instance.deleteMemo(id);
  }

  // Search notes by content
  Future<List<Memo>> searchNotes(String query) async {
    if (query.trim().isEmpty) {
      return await getAllNotes();
    }
    return await MemoService.instance.searchMemos(query);
  }

  // Search notes by tags
  Future<List<Memo>> searchNotesByTags(List<String> tags) async {
    if (tags.isEmpty) {
      return await getAllNotes();
    }

    final allNotes = await getAllNotes();
    return allNotes
        .where((note) => tags.any((tag) => note.tags.contains(tag)))
        .toList();
  }

  // Get all unique tags
  Future<List<String>> getAllTags() async {
    return await MemoService.instance.getAllTags();
  }

  // Close the connection
  Future<void> close() async {
    // Memo service doesn't require explicit closing
  }
}
