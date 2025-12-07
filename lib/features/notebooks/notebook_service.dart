import 'package:mindlog/utils/log_util.dart';
import 'package:mindlog/features/notebooks/data/notebook_database_repository.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:get/get.dart';

class NotebookService extends GetxService {
  NotebookDatabaseRepository? _repository;

  static NotebookService get instance => Get.find<NotebookService>();

  NotebookDatabaseRepository get repository {
    if (_repository == null) {
      throw Exception('NotebookService not initialized. Call init() first.');
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
    await _migrateSortIndex();
  }

  Future<void> _initializeRepository() async {
    // Don't close the repository here since it uses shared database
    if (_repository == null) {
      // Create database repository for UUID support
      _repository = NotebookDatabaseRepository();
      await _repository!
          .initialize(); // The repository is not null at this point, so using ! is safe
    }
  }

  /// Migrate existing notebooks to have proper sort_index values after schema update
  Future<void> _migrateSortIndex() async {
    try {
      final allNotebooks = await getAllNotebooks();

      // Check if there are notebooks with sortIndex=0 that may be old notebooks
      // If there are notebooks with the same sortIndex, it indicates a need for migration
      final hasDuplicateSortIndex = allNotebooks
          .map((nb) => nb.sortIndex)
          .toSet()
          .length != allNotebooks.length;

      if (hasDuplicateSortIndex || allNotebooks.any((nb) => nb.sortIndex == 0)) {
        // Sort notebooks by creation time and assign sortIndex accordingly
        final sortedNotebooks = List<Notebook>.from(allNotebooks)
          ..sort((a, b) => a.createTime.compareTo(b.createTime));

        // Update each notebook with the correct sortIndex
        for (int i = 0; i < sortedNotebooks.length; i++) {
          final notebook = sortedNotebooks[i];
          if (notebook.sortIndex != i) {
            final updatedNotebook = notebook.copyWith(sortIndex: i);
            await updateNotebook(updatedNotebook);
          }
        }
      }
    } catch (e) {
      // If migration fails, just continue - it's not critical
      logger.error('Notebook sort index migration failed: $e');
    }
  }

  // Proxy all NotebookStorageRepository methods to current repository
  Future<void> initialize() async {
    if (_repository == null) {
      await init();
    }
    return repository.initialize();
  }

  Future<List<Notebook>> getAllNotebooks() async {
    if (_repository == null) {
      await init();
    }
    return repository.getAllNotebooks();
  }

  Future<Notebook?> getNotebookById(String id) async {
    if (_repository == null) {
      await init();
    }
    return repository.getNotebookById(id);
  }

  Future<String> saveNotebook(Notebook notebook) async {
    if (_repository == null) {
      await init();
    }
    return repository.saveNotebook(notebook);
  }

  Future<void> updateNotebook(Notebook notebook) async {
    if (_repository == null) {
      await init();
    }
    return repository.updateNotebook(notebook);
  }

  Future<void> deleteNotebook(String id) async {
    if (_repository == null) {
      await init();
    }
    return repository.deleteNotebook(id);
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