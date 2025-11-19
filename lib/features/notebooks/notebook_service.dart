import 'package:mindlog/features/notebooks/data/notebook_database_repository.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';

class NotebookService {
  NotebookDatabaseRepository? _repository;

  static NotebookService? _instance;
  static NotebookService get instance {
    _instance ??= NotebookService();
    return _instance!; // This is safe because we just assigned it if it was null
  }

  NotebookDatabaseRepository get repository {
    if (_repository == null) {
      throw Exception('NotebookService not initialized. Call init() first.');
    }
    return _repository!;
  }

  Future<void> init() async {
    await _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    // Don't close the repository here since it uses shared database
    if (_repository == null) {
      // Create database repository for UUID support
      _repository = NotebookDatabaseRepository();
      await _repository!.initialize(); // The repository is not null at this point, so using ! is safe
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
}