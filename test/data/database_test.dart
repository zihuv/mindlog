import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/database/app_database.dart';
import 'package:mindlog/database/note_dao.dart';
import 'package:drift/drift.dart' as drift show Value;

void main() {
  late AppDatabase database;
  late NoteDao noteDao;

  setUp(() async {
    // Use in-memory database for testing
    database = AppDatabase();
    noteDao = NoteDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('AppDatabase and NoteDao Tests', () {
    test('Create and retrieve a note', () async {
      final now = DateTime.now();
      final note = NotesCompanion(
        id: const drift.Value('test-id-1'),
        content: const drift.Value('Test content'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: const drift.Value(['image1.jpg']),
        audioName: const drift.Value(['audio1.mp3']),
        videoName: const drift.Value(['video1.mp4']),
        tags: const drift.Value(['test', 'note']),
        isDeleted: const drift.Value(false),
      );

      // Insert the note
      await noteDao.insertNote(note);

      // Retrieve the note
      final retrievedNote = await noteDao.getNoteById('test-id-1');
      
      expect(retrievedNote, isNotNull);
      expect(retrievedNote!.id, equals('test-id-1'));
      expect(retrievedNote.content, equals('Test content'));
      expect(retrievedNote.imageName, contains('image1.jpg'));
      expect(retrievedNote.audioName, contains('audio1.mp3'));
      expect(retrievedNote.videoName, contains('video1.mp4'));
      expect(retrievedNote.tags, containsAll(['test', 'note']));
      expect(retrievedNote.isDeleted, isFalse);
    });

    test('Update a note', () async {
      final now = DateTime.now();
      final note = NotesCompanion(
        id: const drift.Value('test-id-2'),
        content: const drift.Value('Original content'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: const drift.Value([]),
        audioName: const drift.Value([]),
        videoName: const drift.Value([]),
        tags: const drift.Value([]),
        isDeleted: const drift.Value(false),
      );

      // Insert the note
      await noteDao.insertNote(note);

      // Update the note
      final updatedNote = NotesCompanion(
        id: const drift.Value('test-id-2'),
        content: const drift.Value('Updated content'),
        lastModified: drift.Value(DateTime.now()),
        imageName: const drift.Value([]),
        audioName: const drift.Value([]),
        videoName: const drift.Value([]),
        tags: const drift.Value(['updated']),
        isDeleted: const drift.Value(false),
      );
      
      await noteDao.updateNote(updatedNote, 'test-id-2');

      // Retrieve the updated note
      final retrievedNote = await noteDao.getNoteById('test-id-2');
      
      expect(retrievedNote, isNotNull);
      expect(retrievedNote!.content, equals('Updated content'));
      expect(retrievedNote.tags, contains('updated'));
    });

    test('Soft delete a note', () async {
      final now = DateTime.now();
      final note = NotesCompanion(
        id: const drift.Value('test-id-3'),
        content: const drift.Value('To be deleted'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: const drift.Value([]),
        audioName: const drift.Value([]),
        videoName: const drift.Value([]),
        tags: const drift.Value([]),
        isDeleted: const drift.Value(false),
      );

      // Insert the note
      await noteDao.insertNote(note);

      // Soft delete the note
      await noteDao.deleteNote('test-id-3');

      // Try to retrieve the note - should not appear in regular queries
      final allNotes = await noteDao.getAllNotes();
      expect(allNotes, isEmpty);

      // But should still exist in the database (with isDeleted=true)
      final deletedNote = await noteDao.getNoteById('test-id-3');
      expect(deletedNote, isNotNull);
      expect(deletedNote!.isDeleted, isTrue);
    });

    test('Search notes', () async {
      // Create test notes
      final now = DateTime.now();
      final note1 = NotesCompanion(
        id: const drift.Value('search-test-1'),
        content: const drift.Value('This is a test note about Flutter'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: const drift.Value([]),
        audioName: const drift.Value([]),
        videoName: const drift.Value([]),
        tags: const drift.Value(['flutter', 'test']),
        isDeleted: const drift.Value(false),
      );

      final note2 = NotesCompanion(
        id: const drift.Value('search-test-2'),
        content: const drift.Value('Another note about Dart programming'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: const drift.Value([]),
        audioName: const drift.Value([]),
        videoName: const drift.Value([]),
        tags: const drift.Value(['dart', 'programming']),
        isDeleted: const drift.Value(false),
      );

      await noteDao.insertNote(note1);
      await noteDao.insertNote(note2);

      // Search for "Flutter"
      final flutterResults = await noteDao.searchNotes('Flutter');
      expect(flutterResults.length, equals(1));
      expect(flutterResults.first.id, equals('search-test-1'));

      // Search for "programming"
      final programmingResults = await noteDao.searchNotes('programming');
      expect(programmingResults.length, equals(1));
      expect(programmingResults.first.id, equals('search-test-2'));
    });

    test('Get all tags', () async {
      // Create test notes with tags
      final now = DateTime.now();
      final note1 = NotesCompanion(
        id: const drift.Value('tags-test-1'),
        content: const drift.Value('Note with tags'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: const drift.Value([]),
        audioName: const drift.Value([]),
        videoName: const drift.Value([]),
        tags: const drift.Value(['work', 'important']),
        isDeleted: const drift.Value(false),
      );

      final note2 = NotesCompanion(
        id: const drift.Value('tags-test-2'),
        content: const drift.Value('Another note with tags'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: const drift.Value([]),
        audioName: const drift.Value([]),
        videoName: const drift.Value([]),
        tags: const drift.Value(['personal', 'work']), // 'work' is duplicate
        isDeleted: const drift.Value(false),
      );

      await noteDao.insertNote(note1);
      await noteDao.insertNote(note2);

      final allTags = await noteDao.getAllTags();
      expect(allTags, containsAll(['work', 'important', 'personal']));
      expect(allTags.length, equals(3)); // Should not include duplicates
    });
  });
}