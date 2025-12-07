import 'package:drift/drift.dart' as drift show Value; // Import Value from drift with alias
import 'package:drift/drift.dart';
import 'package:mindlog/data/database/app_database.dart';

part 'notebooks_dao.g.dart';

@DriftAccessor(tables: [Notebooks])
class NotebooksDao extends DatabaseAccessor<AppDatabase> with _$NotebooksDaoMixin {
  NotebooksDao(super.db);

  // Notebook operations
  Future<int> insertNotebook(NotebooksCompanion notebook) =>
      into(notebooks).insert(notebook);

  Future<int> updateNotebook(NotebooksCompanion notebook, String id) {
    return (update(
      notebooks,
    )..where((tbl) => tbl.id.equals(id))).write(notebook);
  }

  Future<List<NotebookData>> getAllNotebooks() {
    return (select(notebooks)).get().then(
      (rows) => rows.map((row) => NotebookData.fromTable(row)).toList(),
    );
  }

  Future<NotebookData?> getNotebookById(String id) async {
    final result = await (select(
      notebooks,
    )..where((tbl) => tbl.id.equals(id))).get();
    if (result.isNotEmpty) {
      return NotebookData.fromTable(result.first);
    }
    return null;
  }

  Future<int> deleteNotebook(String id) {
    return (delete(notebooks)..where((tbl) => tbl.id.equals(id))).go();
  }
}

// Data class for notebook
class NotebookData {
  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final String type;
  final int sortIndex;
  final DateTime createTime;
  final DateTime? updateTime;

  NotebookData({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    required this.type,
    this.sortIndex = 0,
    required this.createTime,
    this.updateTime,
  });

  factory NotebookData.fromTable(Notebook row) {
    return NotebookData(
      id: row.id,
      title: row.title,
      description: row.description,
      coverImage: row.coverImage,
      type: row.type,
      sortIndex: row.sortIndex,
      createTime: row.createTime,
      updateTime: row.updateTime,
    );
  }

  // Convert to drift companion for database operations
  NotebooksCompanion toCompanion() {
    return NotebooksCompanion(
      id: drift.Value(id),
      title: drift.Value(title),
      description: drift.Value(description),
      coverImage: drift.Value(coverImage),
      type: drift.Value(type),
      sortIndex: drift.Value(sortIndex),
      createTime: drift.Value(createTime),
      updateTime: drift.Value(updateTime),
    );
  }
}