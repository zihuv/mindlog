import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';

abstract class NotebookStorageRepository {
  Future<void> initialize();
  Future<List<Notebook>> getAllNotebooks();
  Future<Notebook?> getNotebookById(String id);
  Future<String> saveNotebook(Notebook notebook);
  Future<void> updateNotebook(Notebook notebook);
  Future<void> deleteNotebook(String id);
  Future<void> close();
}
