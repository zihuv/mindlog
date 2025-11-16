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
        time: drift.Value(note.createdAt),
        lastModified: drift.Value(note.updatedAt ?? note.createdAt),
        imageName: drift.Value(note.images),
        audioName: drift.Value(note.audios),
        videoName: drift.Value(note.videos),
        tags: drift.Value(note.tags),
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
        time: drift.Value(note.createdAt), // Keep original creation time
        lastModified: drift.Value(note.updatedAt ?? DateTime.now()),
        imageName: drift.Value(note.images),
        audioName: drift.Value(note.audios),
        videoName: drift.Value(note.videos),
        tags: drift.Value(note.tags),
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
    return await _noteDao.getAllTags();
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
      createdAt: noteData.time,
      updatedAt: noteData.lastModified != noteData.time
          ? noteData.lastModified
          : null,
      isPinned: false, // Not stored in DB, default to false
      visibility: 'PRIVATE', // Not stored in DB, default to PRIVATE
      notebookId: noteData.notebookId,
      tags: noteData.tags,
      images: noteData.imageName,
      videos: noteData.videoName,
      audios: noteData.audioName,
      checklistStates: const {}, // Not stored in DB, default to empty
    );
  }
}
