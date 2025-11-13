import 'package:drift/drift.dart';
import 'package:mindlog/database/app_database.dart';
import 'package:mindlog/database/note_dao.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:uuid/uuid.dart';

import 'memo_storage_repository.dart';

class MemoDatabaseRepository implements MemoStorageRepository {
  late AppDatabase _database;
  late NoteDao _noteDao;
  final Uuid _uuid = const Uuid();

  @override
  Future<void> initialize() async {
    _database = AppDatabase();
    _noteDao = NoteDao(_database);
  }

  @override
  Future<List<Memo>> getAllMemos() async {
    final noteDataList = await _noteDao.getAllNotes();
    return noteDataList
        .where((note) => !note.isDeleted)
        .map(_mapNoteDataToMemo)
        .toList();
  }

  @override
  Future<Memo?> getMemoById(String id) async {
    final noteData = await _noteDao.getNoteById(id);
    if (noteData == null || noteData.isDeleted) {
      return null;
    }
    return _mapNoteDataToMemo(noteData);
  }

  @override
  Future<void> saveMemo(Memo memo) async {
    // Generate a UUID if the memo doesn't have an ID yet
    final id = memo.id.isEmpty ? _uuid.v7() : memo.id;

    await _noteDao.insertNote(
      NotesCompanion(
        id: Value(id),
        content: Value(memo.content),
        time: Value(memo.createdAt),
        lastModified: Value(memo.updatedAt ?? memo.createdAt),
        imageName: Value(memo.images),
        audioName: Value(memo.audios),
        videoName: Value(memo.videos),
        tags: Value(memo.tags),
        isDeleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> updateMemo(Memo memo) async {
    await _noteDao.updateNote(
      NotesCompanion(
        content: Value(memo.content),
        time: Value(memo.createdAt), // Keep original creation time
        lastModified: Value(memo.updatedAt ?? DateTime.now()),
        imageName: Value(memo.images),
        audioName: Value(memo.audios),
        videoName: Value(memo.videos),
        tags: Value(memo.tags),
        // Note: isDeleted is a flag for soft delete, not the same as isPinned
      ),
      memo.id,
    );
  }

  @override
  Future<void> deleteMemo(String id) async {
    await _noteDao.deleteNote(id);
  }

  @override
  Future<List<Memo>> searchMemos(String query) async {
    if (query.trim().isEmpty) return await getAllMemos();
    final noteDataList = await _noteDao.searchNotes(query);
    return noteDataList
        .where((note) => !note.isDeleted)
        .map(_mapNoteDataToMemo)
        .toList();
  }

  @override
  Future<List<String>> getAllTags() async {
    return await _noteDao.getAllTags();
  }

  @override
  Future<void> close() async {
    await _database.close();
  }

  Memo _mapNoteDataToMemo(NoteData noteData) {
    return Memo(
      id: noteData.id, // Use the string ID directly
      content: noteData.content,
      createdAt: noteData.time,
      updatedAt: noteData.lastModified != noteData.time
          ? noteData.lastModified
          : null,
      isPinned: false, // Not stored in DB, default to false
      visibility: 'PRIVATE', // Not stored in DB, default to PRIVATE
      tags: noteData.tags,
      images: noteData.imageName,
      videos: noteData.videoName,
      audios: noteData.audioName,
      checklistStates: const {}, // Not stored in DB, default to empty
    );
  }
}
