import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/database/app_database.dart' hide Note;
import 'package:mindlog/database/note_dao.dart';
import 'package:mindlog/features/notes/data/note_service.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late NoteDao noteDao;
  late NoteService noteService;

  setUp(() {
    database = AppDatabase();
    noteDao = NoteDao(database);
    noteService = NoteService();
    noteService.init();
  });

  tearDown(() async {
    noteService.close();
  });

  test('Save and retrieve note via service', () async {
    const uuid = Uuid();
    final noteId = uuid.v7();
    final now = DateTime.now();

    // Create a note entity
    final note = Note(
      id: noteId,
      content: 'Test note content',
      createTime: now,
      images: ['image1.jpg', 'image2.png'],
      audios: ['voice_note.mp3'],
      videos: ['vacation_video.mp4'],
    );

    // Save the note
    await noteService.saveNote(note);

    // Retrieve the note
    final retrievedNote = await noteService.getNoteById(noteId);

    expect(retrievedNote, isNotNull);
    expect(retrievedNote!.id, noteId);
    expect(retrievedNote.content, 'Test note content');
    expect(retrievedNote.images, ['image1.jpg', 'image2.png']);
    expect(retrievedNote.audios, ['voice_note.mp3']);
    expect(retrievedNote.videos, ['vacation_video.mp4']);
  });

  test('Note CRUD operations via service', () async {
    // Create a note
    const uuid = Uuid();
    final noteId = uuid.v7();
    final now = DateTime.now();
    final note = Note(
      id: noteId,
      content: 'Sample note content',
      createTime: now,
      images: [],
      audios: [],
      videos: [],
    );

    // Save the note
    await noteService.saveNote(note);

    // Retrieve the note
    final retrievedNote = await noteService.getNoteById(noteId);
    expect(retrievedNote, isNotNull);
    expect(retrievedNote!.content, 'Sample note content');

    // Update the note by saving it again with new content
    final updatedNote = Note(
      id: noteId,
      content: 'Updated note content',
      createTime: now,
      updateTime: now,
      images: [],
      audios: [],
      videos: [],
    );
    await noteService.updateNote(updatedNote);

    // Verify the update
    final updatedRetrievedNote = await noteService.getNoteById(noteId);
    expect(updatedRetrievedNote!.content, 'Updated note content');

    // Test delete
    await noteService.deleteNote(noteId);
    final deletedNote = await noteService.getNoteById(noteId);
    expect(deletedNote, isNull);

    // Check if it's soft deleted (still in database but marked as deleted)
    final allNotes = await noteDao.getAllNotes();
    expect(allNotes.any((note) => note.id == noteId), false);
  });
}
