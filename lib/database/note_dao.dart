import 'package:drift/drift.dart'
    as drift
    show Value; // Import Value from drift with alias
import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'note_dao.g.dart';

@DriftAccessor(tables: [Notes, Notebooks])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(super.db);

  // Insert or update a note
  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);

  // Update an existing note
  Future<int> updateNote(NotesCompanion note, String id) {
    return (update(notes)..where((tbl) => tbl.id.equals(id))).write(note);
  }

  // Get all notes (excluding deleted ones)
  Future<List<NoteData>> getAllNotes() {
    return (select(notes)..where((tbl) => tbl.isDeleted.equals(false)))
        .get()
        .then((rows) => rows.map((row) => NoteData.fromTable(row)).toList());
  }

  // Get a single note by ID
  Future<NoteData?> getNoteById(String id) async {
    final result = await (select(
      notes,
    )..where((tbl) => tbl.id.equals(id))).get();
    if (result.isNotEmpty) {
      return NoteData.fromTable(result.first);
    }
    return null;
  }

  // Search notes by content with support for search term matching
  Future<List<NoteData>> searchNotes(String query) {
    if (query.isEmpty) {
      return (select(notes)..where((tbl) => tbl.isDeleted.equals(false)))
          .get()
          .then((rows) => rows.map((row) => NoteData.fromTable(row)).toList());
    }

    // Search in content, tags and any other relevant fields
    return (select(notes)..where(
          (tbl) => tbl.isDeleted.equals(false) & tbl.content.contains(query),
        ))
        .get()
        .then((rows) => rows.map((row) => NoteData.fromTable(row)).toList());
  }

  // Soft delete a note
  Future<int> deleteNote(String id) {
    return (update(notes)..where((tbl) => tbl.id.equals(id))).write(
      const NotesCompanion(isDeleted: drift.Value(true)),
    );
  }

  // Permanently delete a note (not used by default, kept for future use)
  Future<int> permanentlyDeleteNote(String id) {
    return (delete(notes)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get all notes with a specific tag - functionality removed with tags column
  Future<List<NoteData>> getNotesByTag(String tag) async {
    // Since tags column was removed, return empty list
    return [];
  }

  // Get all tags used in notes - functionality removed with tags column
  Future<List<String>> getAllTags() async {
    // Since tags column was removed, return empty list
    return [];
  }

  // Notebook operations
  Future<int> insertNotebook(NotebooksCompanion notebook) => into(notebooks).insert(notebook);

  Future<int> updateNotebook(NotebooksCompanion notebook, String id) {
    return (update(notebooks)..where((tbl) => tbl.id.equals(id))).write(notebook);
  }

  Future<List<NotebookData>> getAllNotebooks() {
    return (select(notebooks)).get().then(
      (rows) => rows.map((row) => NotebookData.fromTable(row)).toList(),
    );
  }

  Future<NotebookData?> getNotebookById(String id) async {
    final result = await (select(notebooks)..where((tbl) => tbl.id.equals(id))).get();
    if (result.isNotEmpty) {
      return NotebookData.fromTable(result.first);
    }
    return null;
  }

  Future<int> deleteNotebook(String id) {
    return (delete(notebooks)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<NoteData>> getNotesByNotebookId(String notebookId) {
    return (select(notes)..where((tbl) => tbl.notebookId.equals(notebookId) & tbl.isDeleted.equals(false)))
        .get()
        .then((rows) => rows.map((row) => NoteData.fromTable(row)).toList());
  }
}

// Data class for note
class NoteData {
  final String id;
  final String content;
  final DateTime time;
  final DateTime lastModified;
  final List<String> imageName;
  final List<String> audioName;
  final List<String> videoName;
  final String? notebookId;
  final bool isDeleted;

  NoteData({
    required this.id,
    required this.content,
    required this.time,
    required this.lastModified,
    required this.imageName,
    required this.audioName,
    required this.videoName,
    this.notebookId,
    required this.isDeleted,
  });

  factory NoteData.fromTable(Note row) {
    return NoteData(
      id: row.id,
      content: row.content,
      time: row.time,
      lastModified: row.lastModified,
      imageName: row.imageName,
      audioName: row.audioName,
      videoName: row.videoName,
      notebookId: row.notebookId,
      isDeleted: row.isDeleted,
    );
  }

  // Convert to drift companion for database operations
  NotesCompanion toCompanion() {
    return NotesCompanion(
      id: drift.Value(id),
      content: drift.Value(content),
      time: drift.Value(time),
      lastModified: drift.Value(lastModified),
      imageName: Value(imageName),
      audioName: Value(audioName),
      videoName: Value(videoName),
      notebookId: Value(notebookId),
      isDeleted: Value(isDeleted),
    );
  }
}

// Data class for notebook
class NotebookData {
  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final String type;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NotebookData({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    required this.type,
    required this.createdAt,
    this.updatedAt,
  });

  factory NotebookData.fromTable(Notebook row) {
    return NotebookData(
      id: row.id,
      title: row.title,
      description: row.description,
      coverImage: row.coverImage,
      type: row.type,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
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
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
    );
  }
}
