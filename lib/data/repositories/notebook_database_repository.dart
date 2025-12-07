import 'package:drift/drift.dart' as drift;
import 'package:mindlog/data/database/app_database.dart';
import 'package:mindlog/data/database/note_dao.dart';
import 'package:mindlog/data/models/notebook.dart'
    as domain_notebook;
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

import 'notebook_storage_repository.dart';

class NotebookDatabaseRepository implements NotebookStorageRepository {
  late AppDatabase _database;
  late NoteDao _noteDao;
  final Uuid _uuid = const Uuid();

  @override
  Future<void> initialize() async {
    _database = Get.find<DatabaseProvider>().database;
    _noteDao = NoteDao(_database);
  }

  @override
  @override
  Future<List<domain_notebook.Notebook>> getAllNotebooks() async {
    final notebookDataList = await _noteDao.getAllNotebooks();
    return notebookDataList.map(_mapNotebookDataToNotebook).toList();
  }

  @override
  Future<domain_notebook.Notebook?> getNotebookById(String id) async {
    final notebookData = await _noteDao.getNotebookById(id);
    if (notebookData == null) {
      return null;
    }
    return _mapNotebookDataToNotebook(notebookData);
  }

  @override
  Future<String> saveNotebook(domain_notebook.Notebook notebook) async {
    // Generate a UUID if the notebook doesn't have an ID yet
    final id = notebook.id.isEmpty ? _uuid.v7() : notebook.id;

    await _noteDao.insertNotebook(
      NotebooksCompanion(
        id: drift.Value(id),
        title: drift.Value(notebook.title),
        description: drift.Value(notebook.description),
        coverImage: drift.Value(notebook.coverImage),
        type: drift.Value(notebook.type.toString().split('.').last.toLowerCase()),
        sortIndex: drift.Value(notebook.sortIndex),
        createTime: drift.Value(notebook.createTime),
        updateTime: drift.Value(notebook.updateTime),
      ),
    );

    return id;
  }

  @override
  Future<void> updateNotebook(domain_notebook.Notebook notebook) async {
    await _noteDao.updateNotebook(
      NotebooksCompanion(
        title: drift.Value(notebook.title),
        description: drift.Value(notebook.description),
        coverImage: drift.Value(notebook.coverImage),
        type: drift.Value(notebook.type.toString().split('.').last.toLowerCase()),
        sortIndex: drift.Value(notebook.sortIndex),
        createTime: drift.Value(
          notebook.createTime,
        ), // Keep original creation createTime
        updateTime: drift.Value(notebook.updateTime ?? DateTime.now()),
      ),
      notebook.id,
    );
  }

  @override
  Future<void> deleteNotebook(String id) async {
    await _noteDao.deleteNotebook(id);
  }

  @override
  Future<void> close() async {
    // Don't close the shared database instance here
    // The database will be closed by the DatabaseProvider when appropriate
  }

  domain_notebook.Notebook _mapNotebookDataToNotebook(
    NotebookData notebookData,
  ) {
    return domain_notebook.Notebook(
      id: notebookData.id,
      title: notebookData.title,
      description: notebookData.description,
      coverImage: notebookData.coverImage,
      type: _getNotebookTypeFromString(notebookData.type),
      sortIndex: notebookData.sortIndex,
      createTime: notebookData.createTime,
      updateTime: notebookData.updateTime,
    );
  }

  domain_notebook.NotebookType _getNotebookTypeFromString(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'checklist':
        return domain_notebook.NotebookType.checklist;
      case 'timer':
        return domain_notebook.NotebookType.timer;
      case 'standard':
      default:
        return domain_notebook.NotebookType.standard;
    }
  }
}
