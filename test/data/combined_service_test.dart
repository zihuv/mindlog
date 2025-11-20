import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/data/services/combined_note_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CombinedNoteService service;

  setUp(() async {
    service = CombinedNoteService();
    await service.init();
  });

  tearDown(() async {
    await service.close();
  });

  group('CombinedNoteService Tests', () {
    test('Create note with media', () async {
      final tempDir = await getTemporaryDirectory();
      final testImage = File(path.join(tempDir.path, 'test_image.jpg'));
      await testImage.writeAsBytes([0, 1, 2, 3, 4]);

      final noteId = await service.createNote(
        content: 'Test note with media',
        imagesToCopy: [testImage.path],
      );

      // Verify note was created
      final note = await service.getNoteById(noteId);
      expect(note, isNotNull);
      expect(note!.content, equals('Test note with media'));

      // Verify media was saved
      final media = await service.getNoteMedia(noteId);
      expect(media['images']!.length, equals(1));

      // Clean up
      await testImage.delete();
      await service.deleteNote(noteId);
    });

    test('Update note with new media', () async {
      final tempDir = await getTemporaryDirectory();
      final testImage1 = File(path.join(tempDir.path, 'test_image1.jpg'));
      await testImage1.writeAsBytes([0, 1, 2, 3, 4]);

      // Create initial note
      final noteId = await service.createNote(
        content: 'Initial note content',
        imagesToCopy: [testImage1.path],
      );

      // Add new media to the note
      final testImage2 = File(path.join(tempDir.path, 'test_image2.jpg'));
      await testImage2.writeAsBytes([5, 6, 7, 8, 9]);

      await service.updateNote(
        id: noteId,
        newImagesToCopy: [testImage2.path],
        content: 'Updated note content',
      );

      // Verify note was updated
      final updatedNote = await service.getNoteById(noteId);
      expect(updatedNote!.content, equals('Updated note content'));

      // Verify both media files exist
      final media = await service.getNoteMedia(noteId);
      expect(media['images']!.length, equals(2));

      // Clean up
      await testImage1.delete();
      await testImage2.delete();
      await service.deleteNote(noteId);
    });

    test('Delete note with media', () async {
      final tempDir = await getTemporaryDirectory();
      final testImage = File(path.join(tempDir.path, 'test_image.jpg'));
      await testImage.writeAsBytes([0, 1, 2, 3, 4]);

      final noteId = await service.createNote(
        content: 'Note to be deleted with media',
        imagesToCopy: [testImage.path],
      );

      // Verify note and media exist
      final note = await service.getNoteById(noteId);
      expect(note, isNotNull);

      final media = await service.getNoteMedia(noteId);
      expect(media['images']!.length, equals(1));

      // Delete the note (which should also delete media)
      await service.deleteNote(noteId);

      // Verify note is deleted
      final deletedNote = await service.getNoteById(noteId);
      expect(deletedNote, isNull);

      // Verify media is deleted
      final mediaAfterDelete = await service.getNoteMedia(noteId);
      expect(mediaAfterDelete['images']!.length, equals(0));

      // Clean up
      await testImage.delete();
    });

    test('Search notes', () async {
      // Create test notes
      await service.createNote(content: 'This is a Flutter development note');

      await service.createNote(content: 'Dart programming concepts note');

      // Search for Flutter note
      final flutterResults = await service.searchNotes('Flutter');
      expect(flutterResults.length, equals(1));
      expect(flutterResults.first.content, contains('Flutter'));

      // Search for Dart note
      final dartResults = await service.searchNotes('Dart');
      expect(dartResults.length, equals(1));
      expect(dartResults.first.content, contains('Dart'));

      // Get all notes
      final allNotes = await service.getAllNotes();
      expect(allNotes.length, equals(2));

      // Clean up - delete all created notes
      for (final note in allNotes) {
        await service.deleteNote(note.id);
      }
    });

    test('Get all tags', () async {
      // Tags functionality has been removed from the app
      final allTags = await service.getAllTags();
      expect(allTags, isEmpty);
    });
  });
}
