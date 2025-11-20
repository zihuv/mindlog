import 'package:drift/drift.dart' as drift;
import 'package:mindlog/database/app_database.dart' as db;
import 'package:mindlog/database/note_dao.dart' show NoteDao, NoteData;
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:uuid/uuid.dart';

import 'note_storage_repository.dart';

class NoteDatabaseRepository implements NoteStorageRepository {
  late db.AppDatabase _database;
  late NoteDao _noteDao;
  final Uuid _uuid = const Uuid();

  @override
  Future<void> initialize() async {
    _database = db.DatabaseProvider.instance.database;
    _noteDao = NoteDao(_database);
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final noteDataList = await _noteDao.getAllNotes();
    return noteDataList
        .where((note) => !note.isDeleted)
        .map(_mapNoteDataToNote)
        .toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final noteData = await _noteDao.getNoteById(id);
    if (noteData == null || noteData.isDeleted) {
      return null;
    }
    return _mapNoteDataToNote(noteData);
  }

  @override
  Future<void> saveNote(Note note) async {
    // Generate a UUID if the note doesn't have an ID yet
    final id = note.id.isEmpty ? _uuid.v7() : note.id;

    await _noteDao.insertNote(
      db.NotesCompanion(
        id: drift.Value(id),
        content: drift.Value(note.content),
        createTime: drift.Value(note.createTime),
        updateTime: drift.Value(note.updateTime ?? note.createTime),
        imageName: drift.Value(note.images),
        audioName: drift.Value(note.audios),
        videoName: drift.Value(note.videos),
        notebookId: drift.Value(note.notebookId),
        isDeleted: const drift.Value(false),
      ),
    );
  }

  @override
  Future<void> updateNote(Note note) async {
    await _noteDao.updateNote(
      db.NotesCompanion(
        content: drift.Value(note.content),
        createTime: drift.Value(
          note.createTime,
        ), // Keep original creation createTime
        updateTime: drift.Value(note.updateTime ?? DateTime.now()),
        imageName: drift.Value(note.images),
        audioName: drift.Value(note.audios),
        videoName: drift.Value(note.videos),
        notebookId: drift.Value(note.notebookId),
        // Note: isDeleted is a flag for soft delete, not the same as isPinned
      ),
      note.id,
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    await _noteDao.deleteNote(id);
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    if (query.trim().isEmpty) return await getAllNotes();
    final noteDataList = await _noteDao.searchNotes(query);
    return noteDataList
        .where((note) => !note.isDeleted)
        .map(_mapNoteDataToNote)
        .toList();
  }

  @override
  Future<List<Note>> getNotesByNotebookId(String notebookId) async {
    final noteDataList = await _noteDao.getNotesByNotebookId(notebookId);
    return noteDataList
        .where((note) => !note.isDeleted)
        .map(_mapNoteDataToNote)
        .toList();
  }

  @override
  Future<List<String>> getAllTags() async {
    // Tags functionality has been removed from the app
    return [];
  }

  @override
  Future<void> close() async {
    // Don't close the shared database instance here
    // The database will be closed by the DatabaseProvider when appropriate
  }

  Note _mapNoteDataToNote(NoteData noteData) {
    return Note(
      id: noteData.id, // Use the string ID directly
      content: noteData.content,
      createTime: noteData.createTime,
      updateTime: noteData.updateTime != noteData.createTime
          ? noteData.updateTime
          : null,
      notebookId: noteData.notebookId,
      images: noteData.imageName,
      videos: noteData.videoName,
      audios: noteData.audioName,
    );
  }
}
