import 'package:drift/drift.dart'
    as drift
    show Value; // Import Value from drift with alias
import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'note_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(AppDatabase db) : super(db);

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

  // Get all notes with a specific tag
  Future<List<NoteData>> getNotesByTag(String tag) async {
    final result = await customSelect(
      '''SELECT * FROM notes WHERE is_deleted = 0 AND tags LIKE ?''',
      variables: [Variable.withString('%$tag%')],
    ).get();

    return result.map((row) {
      final tagsStr = row.read<String>('tags');
      final imageNameStr = row.read<String>('imageName');
      final audioNameStr = row.read<String>('audioName');
      final videoNameStr = row.read<String>('videoName');

      return NoteData(
        id: row.read<String>('id'),
        content: row.read<String>('content'),
        time: row.read<DateTime>('time'),
        lastModified: row.read<DateTime>('lastModified'),
        imageName: const ListToStringConverter().mapToDart(imageNameStr),
        audioName: const ListToStringConverter().mapToDart(audioNameStr),
        videoName: const ListToStringConverter().mapToDart(videoNameStr),
        tags: const ListToStringConverter().mapToDart(tagsStr),
        isDeleted: row.read<bool>('isDeleted'),
      );
    }).toList();
  }

  // Get all tags used in notes
  Future<List<String>> getAllTags() async {
    final result = await customSelect(
      'SELECT DISTINCT tags FROM notes WHERE is_deleted = 0',
    ).get();
    final allTags = <String>{};
    for (final row in result) {
      final tagsStr = row.read<String>('tags');
      const converter = ListToStringConverter();
      allTags.addAll(converter.mapToDart(tagsStr));
    }
    return allTags.toList();
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
  final List<String> tags;
  final bool isDeleted;

  NoteData({
    required this.id,
    required this.content,
    required this.time,
    required this.lastModified,
    required this.imageName,
    required this.audioName,
    required this.videoName,
    required this.tags,
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
      tags: row.tags,
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
      imageName: drift.Value(imageName),
      audioName: drift.Value(audioName),
      videoName: drift.Value(videoName),
      tags: drift.Value(tags),
      isDeleted: drift.Value(isDeleted),
    );
  }
}
