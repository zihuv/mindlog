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

    // Clean up cache files after they have been saved to the note directory
    if (imagesToCopy != null || videosToCopy != null || audiosToCopy != null) {
      final allMediaPaths = <String>[];
      if (imagesToCopy != null) allMediaPaths.addAll(imagesToCopy);
      if (videosToCopy != null) allMediaPaths.addAll(videosToCopy);
      if (audiosToCopy != null) allMediaPaths.addAll(audiosToCopy);

      await _mediaService.cleanupCacheFiles(allMediaPaths);
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

    // Add new media files if provided
    List<String>? updatedImageNames = existingNote.images;
    List<String>? updatedVideoNames = existingNote.videos;
    List<String>? updatedAudioNames = existingNote.audios;

    if (newImagesToCopy != null) {
      List<String> newImageNames = [];
      for (final imagePath in newImagesToCopy) {
        await _mediaService.saveImage(id, imagePath.split('/').last, imagePath);
        newImageNames.add(imagePath.split('/').last);
      }
      updatedImageNames = [...existingNote.images, ...newImageNames];
    }

    if (newVideosToCopy != null) {
      List<String> newVideoNames = [];
      for (final videoPath in newVideosToCopy) {
        await _mediaService.saveVideo(id, videoPath.split('/').last, videoPath);
        newVideoNames.add(videoPath.split('/').last);
      }
      updatedVideoNames = [...existingNote.videos, ...newVideoNames];
    }

    if (newAudiosToCopy != null) {
      List<String> newAudioNames = [];
      for (final audioPath in newAudiosToCopy) {
        await _mediaService.saveAudio(id, audioPath.split('/').last, audioPath);
        newAudioNames.add(audioPath.split('/').last);
      }
      updatedAudioNames = [...existingNote.audios, ...newAudioNames];
    }

    // Update the note with all the information
    await _noteService.updateNote(
      id: id,
      content: content,
      imageName: updatedImageNames,
      audioName: updatedAudioNames,
      videoName: updatedVideoNames,
      notebookId: notebookId,
    );

    // Clean up cache files after they have been saved to the note directory
    if (newImagesToCopy != null || newVideosToCopy != null || newAudiosToCopy != null) {
      final allMediaPaths = <String>[];
      if (newImagesToCopy != null) allMediaPaths.addAll(newImagesToCopy);
      if (newVideosToCopy != null) allMediaPaths.addAll(newVideosToCopy);
      if (newAudiosToCopy != null) allMediaPaths.addAll(newAudiosToCopy);

      await _mediaService.cleanupCacheFiles(allMediaPaths);
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
