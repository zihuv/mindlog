import 'note_business_service.dart';
import 'media_service.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';

class CombinedNoteService {
  final NoteBusinessService _noteService = NoteBusinessService();
  final MediaService _mediaService = MediaService();

  Future<void> init() async {
    await _noteService.init();
  }

  // Create a new note with media files
  Future<String> createNote({
    required String content,
    List<String>? imagesToCopy, // Source paths for images to be copied
    List<String>? videosToCopy, // Source paths for videos to be copied
    List<String>? audiosToCopy, // Source paths for audios to be copied
    String? notebookId,
  }) async {
    // Create the note first
    final noteId = await _noteService.createNote(
      content: content,
      imageName: imagesToCopy?.map((e) => e.split('/').last).toList(),
      videoName: videosToCopy?.map((e) => e.split('/').last).toList(),
      audioName: audiosToCopy?.map((e) => e.split('/').last).toList(),
      notebookId: notebookId,
    );

    // Copy media files to the appropriate directories
    if (imagesToCopy != null) {
      for (final imagePath in imagesToCopy) {
        await _mediaService.saveImage(
          noteId,
          imagePath.split('/').last,
          imagePath,
        );
      }
    }

    if (videosToCopy != null) {
      for (final videoPath in videosToCopy) {
        await _mediaService.saveVideo(
          noteId,
          videoPath.split('/').last,
          videoPath,
        );
      }
    }

    if (audiosToCopy != null) {
      for (final audioPath in audiosToCopy) {
        await _mediaService.saveAudio(
          noteId,
          audioPath.split('/').last,
          audioPath,
        );
      }
    }

    return noteId;
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    return await _noteService.getAllNotes();
  }

  // Get a note by ID
  Future<Note?> getNoteById(String id) async {
    return await _noteService.getNoteById(id);
  }

  // Get all media paths for a note
  Future<Map<String, List<String>>> getNoteMedia(String noteId) async {
    return await _mediaService.getNoteMedia(noteId);
  }

  // Update a note with optional media additions
  Future<void> updateNote({
    required String id,
    String? content,
    List<String>? newImagesToCopy, // New images to add to the note
    List<String>? newVideosToCopy, // New videos to add to the note
    List<String>? newAudiosToCopy, // New audios to add to the note
    String? notebookId,
  }) async {
    final existingNote = await _noteService.getNoteById(id);
    if (existingNote == null) {
      throw Exception('Note with id $id does not exist');
    }

    // Update the note
    await _noteService.updateNote(
      id: id,
      content: content,
      notebookId: notebookId,
    );

    // Add new media files if provided
    if (newImagesToCopy != null) {
      for (final imagePath in newImagesToCopy) {
        await _mediaService.saveImage(id, imagePath.split('/').last, imagePath);
      }
    }

    if (newVideosToCopy != null) {
      for (final videoPath in newVideosToCopy) {
        await _mediaService.saveVideo(id, videoPath.split('/').last, videoPath);
      }
    }

    if (newAudiosToCopy != null) {
      for (final audioPath in newAudiosToCopy) {
        await _mediaService.saveAudio(id, audioPath.split('/').last, audioPath);
      }
    }
  }

  // Delete a note and its associated media
  Future<void> deleteNote(String id) async {
    // Delete all associated media files
    await _mediaService.deleteNoteMedia(id);

    // Then delete the note
    await _noteService.deleteNote(id);
  }

  // Search notes by content
  Future<List<Note>> searchNotes(String query) async {
    return await _noteService.searchNotes(query);
  }

  // Get notes by notebook ID
  Future<List<Note>> getNotesByNotebookId(String notebookId) async {
    return await _noteService.getNotesByNotebookId(notebookId);
  }

  // Get all unique tags
  Future<List<String>> getAllTags() async {
    return await _noteService.getAllTags();
  }

  // Close the services
  Future<void> close() async {
    await _noteService.close();
  }
}
