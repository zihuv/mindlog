import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';

void main() {
  group('Note Entity Tests', () {
    test('Note can be created with required fields only', () {
      final note = Note(
        id: '123',
        content: 'Test content',
        createTime: DateTime.now(),
      );

      expect(note.id, '123');
      expect(note.content, 'Test content');
      expect(note.createTime, isA<DateTime>());
      expect(note.images, isEmpty);
      expect(note.videos, isEmpty);
      expect(note.audios, isEmpty);
      expect(note.notebookId, isNull);
    });

    test('Note can be created with all optional fields', () {
      final now = DateTime.now();
      final note = Note(
        id: '456',
        content: 'Test content with fields',
        createTime: now,
        updateTime: now.add(const Duration(hours: 1)),
        notebookId: 'notebook1',
        images: ['image1.jpg', 'image2.png'],
        videos: ['video1.mp4'],
        audios: ['audio1.mp3'],
      );

      expect(note.id, '456');
      expect(note.content, 'Test content with fields');
      expect(note.createTime, now);
      expect(note.updateTime, now.add(const Duration(hours: 1)));
      expect(note.notebookId, 'notebook1');
      expect(note.images, equals(['image1.jpg', 'image2.png']));
      expect(note.videos, equals(['video1.mp4']));
      expect(note.audios, equals(['audio1.mp3']));
    });

    test('Note copyWith works correctly', () {
      final originalNote = Note(
        id: 'original',
        content: 'Original content',
        createTime: DateTime.now(),
      );

      final updatedNote = originalNote.copyWith(content: 'Updated content');

      expect(updatedNote.id, 'original'); // Should remain unchanged
      expect(updatedNote.content, 'Updated content'); // Should be updated
    });

    test('Note toJson and fromJson work correctly', () {
      final now = DateTime.now();
      final note = Note(
        id: 'json-test',
        content: 'JSON test content',
        createTime: now,
        updateTime: now.add(const Duration(minutes: 30)),
        notebookId: 'notebook-json',
        images: ['image.jpg'],
        videos: ['video.mp4'],
        audios: ['audio.mp3'],
      );

      final json = note.toJson();
      final deserializedNote = Note.fromJson(json);

      expect(deserializedNote.id, 'json-test');
      expect(deserializedNote.content, 'JSON test content');
      expect(
        deserializedNote.createTime.millisecondsSinceEpoch,
        note.createTime.millisecondsSinceEpoch,
      );
      expect(
        deserializedNote.updateTime!.millisecondsSinceEpoch,
        note.updateTime!.millisecondsSinceEpoch,
      );
      expect(deserializedNote.notebookId, 'notebook-json');
      expect(deserializedNote.images, equals(['image.jpg']));
      expect(deserializedNote.videos, equals(['video.mp4']));
      expect(deserializedNote.audios, equals(['audio.mp3']));
    });

    test('Note equality works correctly', () {
      final now = DateTime.now();
      final note1 = Note(
        id: 'eq-test',
        content: 'Equality test',
        createTime: now,
      );

      final note2 = Note(
        id: 'eq-test',
        content: 'Equality test',
        createTime: now,
      );

      final note3 = Note(
        id: 'different-id',
        content: 'Equality test',
        createTime: now,
      );

      expect(note1, equals(note2)); // Same properties should be equal
      expect(note1, isNot(equals(note3))); // Different ID should not be equal
    });
  });
}
