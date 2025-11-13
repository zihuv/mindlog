import 'package:mindlog/features/memos/memo_service.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';

class NoteService {
  // Counter to generate unique integer IDs
  static Future<int> _generateId() async {
    final allMemos = await MemoService.instance.getAllMemos();
    int maxId = 0;
    for (final memo in allMemos) {
      if (memo.id > maxId) {
        maxId = memo.id;
      }
    }
    return maxId + 1;
  }

  Future<void> init() async {
    await MemoService.instance.init();
  }

  // Create a new note
  Future<int> createNote({
    required String content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    List<String>? tags,
    Map<int, bool>? checklistStates,
  }) async {
    final noteId = await _generateId();
    final now = DateTime.now();

    // Create a new memo with the generated ID
    final memo = Memo(
      id: noteId,
      content: content,
      createdAt: now,
      updatedAt: now,
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
  Future<Memo?> getNoteById(int id) async {
    return await MemoService.instance.getMemoById(id);
  }

  // Update a note
  Future<void> updateNote({
    required int id,
    String? content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    List<String>? tags,
    Map<int, bool>? checklistStates,
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
      tags: tags ?? existingNote.tags,
      images: imageName ?? existingNote.images,
      videos: videoName ?? existingNote.videos,
      audios: audioName ?? existingNote.audios,
      checklistStates: checklistStates ?? existingNote.checklistStates,
    );

    await MemoService.instance.updateMemo(updatedNote);
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
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
    return allNotes.where((note) =>
      tags.any((tag) => note.tags.contains(tag))
    ).toList();
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