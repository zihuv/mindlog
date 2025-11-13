import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/database/app_database.dart';
import 'package:mindlog/database/note_dao.dart';
import 'package:mindlog/services/note_service.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  late AppDatabase database;
  late NoteDao noteDao;
  late NoteService noteService;

  setUp(() {
    database = AppDatabase();
    noteDao = NoteDao(database);
    noteService = NoteService();
    noteService.onInit();
  });

  tearDown(() async {
    await database.close();
    noteService.onClose();
  });

  test('Create and retrieve note', () async {
    const uuid = Uuid();
    final noteId = uuid.v7();
    final now = DateTime.now();

    // Create a note
    await noteDao.insertNote(
      NotesCompanion(
        id: drift.Value(noteId),
        content: drift.Value('Test note content'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: drift.Value(['image1.jpg', 'image2.png']),
        audioName: drift.Value(['voice_note.mp3']),
        videoName: drift.Value(['vacation_video.mp4']),
        tags: drift.Value(['生活']),
        isDeleted: const drift.Value(false),
      ),
    );

    // Retrieve the note
    final note = await noteDao.getNoteById(noteId);

    expect(note, isNotNull);
    expect(note!.id, noteId);
    expect(note.content, 'Test note content');
    expect(note.imageName, ['image1.jpg', 'image2.png']);
    expect(note.audioName, ['voice_note.mp3']);
    expect(note.videoName, ['vacation_video.mp4']);
    expect(note.tags, ['生活']);
  });

  test('Search notes functionality', () async {
    const uuid = Uuid();

    // Insert test notes
    final noteId1 = uuid.v7();
    final noteId2 = uuid.v7();
    final now = DateTime.now();

    await noteDao.insertNote(
      NotesCompanion(
        id: drift.Value(noteId1),
        content: drift.Value('This is a test note about programming'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: drift.Value([]),
        audioName: drift.Value([]),
        videoName: drift.Value([]),
        tags: drift.Value(['技术']),
        isDeleted: const drift.Value(false),
      ),
    );

    await noteDao.insertNote(
      NotesCompanion(
        id: drift.Value(noteId2),
        content: drift.Value('This is another note about daily life'),
        time: drift.Value(now),
        lastModified: drift.Value(now),
        imageName: drift.Value([]),
        audioName: drift.Value([]),
        videoName: drift.Value([]),
        tags: drift.Value(['生活']),
        isDeleted: const drift.Value(false),
      ),
    );

    // Test search functionality
    final results = await noteDao.searchNotes('programming');
    expect(results.length, 1);
    expect(results.first.id, noteId1);

    // Test empty search returns all notes
    final allResults = await noteDao.searchNotes('');
    expect(allResults.length, 2);
  });

  test('Note CRUD operations via service', () async {
    // Create a note using the service
    final noteId = await noteService.createNote(
      content: 'Sample note content',
      imageName: ['image1.jpg'],
      audioName: ['audio1.mp3'],
      videoName: ['video1.mp4'],
      tags: ['生活', '技术'],
    );

    // Retrieve the note
    final note = await noteService.getNoteById(noteId);
    expect(note, isNotNull);
    expect(note!.content, 'Sample note content');
    expect(note.imageName, ['image1.jpg']);
    expect(note.audioName, ['audio1.mp3']);
    expect(note.videoName, ['video1.mp4']);
    expect(note.tags, ['生活', '技术']);

    // Update the note
    await noteService.updateNote(
      id: noteId,
      content: 'Updated note content',
      tags: ['更新', '测试'],
    );

    // Verify the update
    final updatedNote = await noteService.getNoteById(noteId);
    expect(updatedNote!.content, 'Updated note content');
    expect(updatedNote.tags, ['更新', '测试']);

    // Test soft delete
    await noteService.deleteNote(noteId);
    final deletedNote = await noteService.getNoteById(noteId);
    expect(deletedNote, isNull);

    // Check if it's soft deleted (still in database but marked as deleted)
    final allNotes = await noteDao.getAllNotes();
    expect(allNotes.any((note) => note.id == noteId), false);
  });
}
