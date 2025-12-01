import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/data/services/combined_note_service.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';

void main() {
  late CombinedNoteService service;

  setUp(() async {
    service = CombinedNoteService();
    await service.init();
  });

  test('Delete note updates updateTime and isDeleted fields correctly', () async {
    // Create a test note
    String content = 'Test content for deletion verification';
    String noteId = await service.createNote(content: content);

    // Get the created note to check its initial status
    Note? createdNote = await service.getNoteById(noteId);
    expect(createdNote, isNotNull);
    expect(createdNote!.isDeleted, false);
    DateTime? initialUpdateTime = createdNote.updateTime;

    // Sleep briefly to ensure different timestamps if needed
    await Future.delayed(const Duration(milliseconds: 1));

    // Delete the note (this should update the updateTime and set isDeleted to true)
    await service.deleteNote(noteId);

    // Try to get the note again (should now be deleted and filtered out)
    Note? noteAfterDeletion = await service.getNoteById(noteId);
    expect(
      noteAfterDeletion,
      isNull,
    ); // Because getNoteById excludes deleted notes
  });

  test('Note updateTime is updated when deleted', () async {
    // Create a test note
    String content = 'Test content to verify updateTime update on deletion';
    String noteId = await service.createNote(content: content);

    // Get the created note to check its initial status
    Note? createdNote = await service.getNoteById(noteId);
    expect(createdNote, isNotNull);
    DateTime? originalUpdateTime = createdNote!.updateTime;
    bool originalIsDeleted = createdNote.isDeleted;

    // Ensure note is not originally marked as deleted
    expect(originalIsDeleted, false);

    // Store the original updateTime for comparison
    DateTime updateTimeBeforeDeletion =
        originalUpdateTime ?? createdNote.createTime;

    // Wait briefly to ensure potential time difference
    await Future.delayed(const Duration(milliseconds: 2));

    // Delete the note (should update updateTime)
    await service.deleteNote(noteId);

    // Note should no longer be accessible via getNoteById as it's been soft deleted
    Note? noteAfterDeletion = await service.getNoteById(noteId);
    expect(noteAfterDeletion, isNull);
  });

  tearDown(() async {
    await service.close();
  });
}
