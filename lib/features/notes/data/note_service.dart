import 'package:mindlog/features/notes/data/note_storage_repository.dart';
import 'package:mindlog/features/notes/data/note_database_repository.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:get/get.dart';

class NoteService extends GetxService {
  NoteStorageRepository? _repository;

  static NoteService get instance => Get.find<NoteService>();

  NoteStorageRepository get repository {
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

  Future<void> close() async {
    // Don't close the repository since it uses shared database
    // The shared database will be closed separately
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
