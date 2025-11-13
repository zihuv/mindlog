import 'dart:io';
import 'package:drift/drift.dart' as drift show Value;
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/note_dao.dart';
import '../media/media_manager.dart';

class NoteService extends GetxService {
  late AppDatabase _database;
  late NoteDao _noteDao;
  late MediaManager _mediaManager;
  static const uuid = Uuid();

  // Initialize the service and set up database
  @override
  void onInit() {
    super.onInit();
    _database = AppDatabase();
    _noteDao = NoteDao(_database);
    _mediaManager = MediaManager();
  }

  @override
  void onClose() {
    _database.close();
    super.onClose();
  }

  // Create a new note
  Future<String> createNote({
    required String content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    List<String>? tags,
    Map<int, bool>? checklistStates,
  }) async {
    final noteId = uuid.v7();
    final now = DateTime.now();
    
    final note = NotesCompanion(
      id: drift.Value(noteId),
      content: drift.Value(content),
      time: drift.Value(now),
      lastModified: drift.Value(now),
      imageName: drift.Value(imageName ?? []),
      audioName: drift.Value(audioName ?? []),
      videoName: drift.Value(videoName ?? []),
      tags: drift.Value(tags ?? []),
      isDeleted: const drift.Value(false),
    );
    
    await _noteDao.insertNote(note);
    return noteId;
  }

  // Get all notes
  Future<List<NoteData>> getAllNotes() async {
    return await _noteDao.getAllNotes();
  }

  // Get a note by ID
  Future<NoteData?> getNoteById(String id) async {
    return await _noteDao.getNoteById(id);
  }

  // Update an existing note
  Future<void> updateNote({
    required String id,
    String? content,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    List<String>? tags,
    Map<int, bool>? checklistStates,
  }) async {
    final note = await _noteDao.getNoteById(id);
    if (note == null) {
      throw Exception('Note with ID $id not found');
    }
    
    final updatedNote = NotesCompanion(
      id: drift.Value(id),
      content: drift.Value(content ?? note.content),
      lastModified: drift.Value(DateTime.now()),
      imageName: drift.Value(imageName ?? note.imageName),
      audioName: drift.Value(audioName ?? note.audioName),
      videoName: drift.Value(videoName ?? note.videoName),
      tags: drift.Value(tags ?? note.tags),
      isDeleted: drift.Value(note.isDeleted),
    );
    
    await _noteDao.updateNote(updatedNote, id);
  }

  // Delete a note (soft delete)
  Future<void> deleteNote(String id) async {
    await _noteDao.deleteNote(id);
    // Optionally delete associated media files as well
    await _mediaManager.deleteNoteMedia(id);
  }

  // Permanently delete a note
  Future<void> permanentlyDeleteNote(String id) async {
    await _noteDao.permanentlyDeleteNote(id);
    await _mediaManager.deleteNoteMedia(id);
  }

  // Search notes by content
  Future<List<NoteData>> searchNotes(String query) async {
    return await _noteDao.searchNotes(query);
  }

  // Get notes by tag
  Future<List<NoteData>> getNotesByTag(String tag) async {
    return await _noteDao.getNotesByTag(tag);
  }

  // Get all tags used in notes
  Future<List<String>> getAllTags() async {
    return await _noteDao.getAllTags();
  }

  // Add a media file to a note
  Future<String?> addMediaToNote(String noteId, File mediaFile, String mediaType, {String? fileName}) async {
    switch (mediaType.toLowerCase()) {
      case 'image':
        return await _mediaManager.saveImage(noteId, mediaFile, fileName: fileName);
      case 'video':
        return await _mediaManager.saveVideo(noteId, mediaFile, fileName: fileName);
      case 'audio':
        return await _mediaManager.saveAudio(noteId, mediaFile, fileName: fileName);
      default:
        throw Exception('Unsupported media type: $mediaType');
    }
  }

  // Get the path to a specific media file for a note
  Future<String?> getMediaPath(String noteId, String mediaName, String mediaType) async {
    switch (mediaType.toLowerCase()) {
      case 'image':
        return await _mediaManager.getImagePath(noteId, mediaName);
      case 'video':
        return await _mediaManager.getVideoPath(noteId, mediaName);
      case 'audio':
        return await _mediaManager.getAudioPath(noteId, mediaName);
      default:
        throw Exception('Unsupported media type: $mediaType');
    }
  }

  // Get all images for a specific note
  Future<List<String>> getNoteImages(String noteId) async {
    return await _mediaManager.getNoteImages(noteId);
  }

  // Get all videos for a specific note
  Future<List<String>> getNoteVideos(String noteId) async {
    return await _mediaManager.getNoteVideos(noteId);
  }

  // Get all audio files for a specific note
  Future<List<String>> getNoteAudio(String noteId) async {
    return await _mediaManager.getNoteAudio(noteId);
  }

  // Delete a specific media file for a note
  Future<void> deleteMediaFromNote(String noteId, String mediaName, String mediaType) async {
    switch (mediaType.toLowerCase()) {
      case 'image':
        await _mediaManager.deleteImage(noteId, mediaName);
        break;
      case 'video':
        await _mediaManager.deleteVideo(noteId, mediaName);
        break;
      case 'audio':
        await _mediaManager.deleteAudio(noteId, mediaName);
        break;
      default:
        throw Exception('Unsupported media type: $mediaType');
    }
  }
}