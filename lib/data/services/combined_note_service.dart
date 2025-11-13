import 'note_service.dart';
import 'media_service.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';

class CombinedNoteService {
  final NoteService _noteService = NoteService();
  final MediaService _mediaService = MediaService();

  Future<void> init() async {
    await _noteService.init();
  }

  // Create a new note with media files
  Future<int> createNote({
    required String content,
    List<String>? imagesToCopy, // Source paths for images to be copied
    List<String>? videosToCopy, // Source paths for videos to be copied
    List<String>? audiosToCopy, // Source paths for audios to be copied
    List<String>? tags,
    Map<int, bool>? checklistStates,
  }) async {
    // Create the note first
    final noteId = await _noteService.createNote(
      content: content,
      imageName: imagesToCopy?.map((e) => e.split('/').last).toList(),
      videoName: videosToCopy?.map((e) => e.split('/').last).toList(),
      audioName: audiosToCopy?.map((e) => e.split('/').last).toList(),
      tags: tags,
      checklistStates: checklistStates,
    );

    // Copy media files to the appropriate directories
    if (imagesToCopy != null) {
      for (final imagePath in imagesToCopy) {
        await _mediaService.saveImage(
          noteId.toString(),
          imagePath.split('/').last,
          imagePath,
        );
      }
    }

    if (videosToCopy != null) {
      for (final videoPath in videosToCopy) {
        await _mediaService.saveVideo(
          noteId.toString(),
          videoPath.split('/').last,
          videoPath,
        );
      }
    }

    if (audiosToCopy != null) {
      for (final audioPath in audiosToCopy) {
        await _mediaService.saveAudio(
          noteId.toString(),
          audioPath.split('/').last,
          audioPath,
        );
      }
    }

    return noteId;
  }

  // Get all notes
  Future<List<Memo>> getAllNotes() async {
    return await _noteService.getAllNotes();
  }

  // Get a note by ID
  Future<Memo?> getNoteById(int id) async {
    return await _noteService.getNoteById(id);
  }

  // Get all media paths for a note
  Future<Map<String, List<String>>> getNoteMedia(int noteId) async {
    return await _mediaService.getNoteMedia(noteId.toString());
  }

  // Update a note with optional media additions
  Future<void> updateNote({
    required int id,
    String? content,
    List<String>? newImagesToCopy, // New images to add to the note
    List<String>? newVideosToCopy, // New videos to add to the note
    List<String>? newAudiosToCopy, // New audios to add to the note
    List<String>? tags,
    Map<int, bool>? checklistStates,
  }) async {
    final existingNote = await _noteService.getNoteById(id);
    if (existingNote == null) {
      throw Exception('Note with id $id does not exist');
    }

    // Update the note
    await _noteService.updateNote(
      id: id,
      content: content,
      tags: tags,
      checklistStates: checklistStates,
    );

    // Add new media files if provided
    if (newImagesToCopy != null) {
      for (final imagePath in newImagesToCopy) {
        await _mediaService.saveImage(
          id.toString(),
          imagePath.split('/').last,
          imagePath,
        );
      }
    }

    if (newVideosToCopy != null) {
      for (final videoPath in newVideosToCopy) {
        await _mediaService.saveVideo(
          id.toString(),
          videoPath.split('/').last,
          videoPath,
        );
      }
    }

    if (newAudiosToCopy != null) {
      for (final audioPath in newAudiosToCopy) {
        await _mediaService.saveAudio(
          id.toString(),
          audioPath.split('/').last,
          audioPath,
        );
      }
    }
  }

  // Delete a note and its associated media
  Future<void> deleteNote(int id) async {
    // Delete all associated media files
    await _mediaService.deleteNoteMedia(id.toString());

    // Then delete the note
    await _noteService.deleteNote(id);
  }

  // Search notes by content
  Future<List<Memo>> searchNotes(String query) async {
    return await _noteService.searchNotes(query);
  }

  // Search notes by tags
  Future<List<Memo>> searchNotesByTags(List<String> tags) async {
    return await _noteService.searchNotesByTags(tags);
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
