import 'package:mindlog/data/repositories/note_database_repository.dart';
import 'package:mindlog/data/models/note.dart';
import 'package:get/get.dart' hide Value;
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:mindlog/data/database/app_database.dart' as db;
import 'package:mindlog/data/database/note_dao.dart';
import 'package:mindlog/utils/media_util.dart';
import 'dart:io';

class NoteService extends GetxService {
  NoteDatabaseRepository? _repository;
  late db.AppDatabase _database;
  late NoteDao _noteDao;
  static const uuid = Uuid();

  static NoteService get instance => Get.find<NoteService>();

  NoteDatabaseRepository get repository {
    if (_repository == null) {
      throw Exception('NoteService not initialized. Call init() first.');
    }
    return _repository!;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize the service when GetX creates it
    init();
    _database = Get.find<db.DatabaseProvider>().database;
    _noteDao = NoteDao(_database);
  }

  Future<void> init() async {
    await _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    // Don't close the repository here since it uses shared database
    if (_repository == null) {
      // Create database repository for UUID support
      _repository = NoteDatabaseRepository();
      await _repository!.initialize();
    }
  }

  // Proxy all NoteStorageRepository methods to current repository
  Future<void> initialize() => repository.initialize();
  Future<List<Note>> getAllNotes() => repository.getAllNotes();
  Future<List<Note>> getAllNotesForSync() => repository.getAllNotesForSync();
  Future<Note?> getNoteById(String id) => repository.getNoteById(id);
  Future<void> saveNote(Note note) => repository.saveNote(note);
  Future<void> updateNote(Note note) => repository.updateNote(note);
  Future<void> deleteNote(String id) => repository.deleteNote(id);
  Future<List<Note>> searchNotes(String query) => repository.searchNotes(query);
  Future<List<Note>> getNotesByNotebookId(String notebookId) =>
      repository.getNotesByNotebookId(notebookId);
  Future<List<Note>> getNotesByDate(DateTime date) =>
      repository.getNotesByDate(date);
  Future<List<String>> getAllTags() async {
    // Tags functionality has been removed from the app
    return [];
  }

  // 添加原来 lib/services/note_service.dart 中的媒体相关方法
  // Create a new note
  Future<String> createNote({
    required String content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    Map<int, bool>? checklistStates,
  }) async {
    final noteId = uuid.v7();
    final now = DateTime.now();

    final note = db.NotesCompanion.insert(
      id: noteId,
      content: content,
      createTime: now,
      updateTime: now,
      imageName: imageName ?? [],
      audioName: audioName ?? [],
      videoName: videoName ?? [],
    );

    await _noteDao.insertNote(note);
    return noteId;
  }

  // Update an existing note
  Future<void> updateNoteDirectly({
    required String id,
    String? content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    Map<int, bool>? checklistStates,
  }) async {
    final note = await _noteDao.getNoteById(id);
    if (note == null) {
      throw Exception('Note with ID $id not found');
    }

    final updatedNote = db.NotesCompanion(
      content: drift.Value(content ?? note.content),
      updateTime: drift.Value(DateTime.now()),
      imageName: drift.Value(imageName ?? note.imageName),
      audioName: drift.Value(audioName ?? note.audioName),
      videoName: drift.Value(videoName ?? note.videoName),
      isDeleted: drift.Value(note.isDeleted),
    );

    await _noteDao.updateNote(updatedNote, id);
  }

  // Add a media file to a note
  Future<String?> addMediaToNote(
    String noteId,
    File mediaFile,
    String mediaType, {
    String? fileName,
  }) async {
    switch (mediaType.toLowerCase()) {
      case 'image':
        return await MediaUtil.saveImage(
          noteId,
          mediaFile,
          fileName: fileName,
        );
      case 'video':
        return await MediaUtil.saveVideo(
          noteId,
          mediaFile,
          fileName: fileName,
        );
      case 'audio':
        return await MediaUtil.saveAudio(
          noteId,
          mediaFile,
          fileName: fileName,
        );
      default:
        throw Exception('Unsupported media type: $mediaType');
    }
  }

  // Get the path to a specific media file for a note
  Future<String?> getMediaPath(
    String noteId,
    String mediaName,
    String mediaType,
  ) async {
    switch (mediaType.toLowerCase()) {
      case 'image':
        return await MediaUtil.getImagePath(noteId, mediaName);
      case 'video':
        return await MediaUtil.getVideoPath(noteId, mediaName);
      case 'audio':
        return await MediaUtil.getAudioPath(noteId, mediaName);
      default:
        throw Exception('Unsupported media type: $mediaType');
    }
  }

  // Get all images for a specific note
  Future<List<String>> getNoteImages(String noteId) async {
    return await MediaUtil.getNoteImages(noteId);
  }

  // Get all videos for a specific note
  Future<List<String>> getNoteVideos(String noteId) async {
    return await MediaUtil.getNoteVideos(noteId);
  }

  // Get all audio files for a specific note
  Future<List<String>> getNoteAudio(String noteId) async {
    return await MediaUtil.getNoteAudio(noteId);
  }

  // Delete a specific media file for a note
  Future<void> deleteMediaFromNote(
    String noteId,
    String mediaName,
    String mediaType,
  ) async {
    switch (mediaType.toLowerCase()) {
      case 'image':
        await MediaUtil.deleteImage(noteId, mediaName);
        break;
      case 'video':
        await MediaUtil.deleteVideo(noteId, mediaName);
        break;
      case 'audio':
        await MediaUtil.deleteAudio(noteId, mediaName);
        break;
      default:
        throw Exception('Unsupported media type: $mediaType');
    }
  }

  // Permanently delete a note
  Future<void> permanentlyDeleteNote(String id) async {
    await _noteDao.permanentlyDeleteNote(id);
    await MediaUtil.deleteNoteMedia(id);
  }

  Future<void> close() async {
    // Don't close the repository since it uses shared database
    // The shared database will be closed separately
    // await _database.close();
  }

  // Reset the service to force re-initialization (used after database import)
  Future<void> reset() async {
    // Close the repository connection
    await _repository?.close();
    _repository = null;
    // Re-initialize on next access
    await init();
  }
}
