import 'note_business_service.dart';
import 'package:mindlog/utils/media_util.dart';
import 'package:mindlog/data/models/note.dart';
import 'package:mindlog/data/services/note_service.dart';
import 'package:get/get.dart';

class CombinedNoteService {
  final NoteBusinessService _noteService = NoteBusinessService();

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
    // Generate new UUID-based filenames for all media files
    final imageNames = imagesToCopy?.map((e) => MediaUtil.generateImageFilename(e)).toList();
    final videoNames = videosToCopy?.map((e) => MediaUtil.generateVideoFilename(e)).toList();
    final audioNames = audiosToCopy?.map((e) => MediaUtil.generateAudioFilename(e)).toList();

    // Create the note first with the new UUID-based filenames
    final noteId = await _noteService.createNote(
      content: content,
      imageName: imageNames,
      videoName: videoNames,
      audioName: audioNames,
      notebookId: notebookId,
    );

    // Copy media files to the appropriate directories using the UUID-based filenames
    if (imagesToCopy != null) {
      for (int i = 0; i < imagesToCopy.length; i++) {
        await MediaUtil.saveImageToNote(
          noteId,
          imageNames![i],
          imagesToCopy[i],
        );
      }
    }

    if (videosToCopy != null) {
      for (int i = 0; i < videosToCopy.length; i++) {
        await MediaUtil.saveVideoToNote(
          noteId,
          videoNames![i],
          videosToCopy[i],
        );
      }
    }

    if (audiosToCopy != null) {
      for (int i = 0; i < audiosToCopy.length; i++) {
        await MediaUtil.saveAudioToNote(
          noteId,
          audioNames![i],
          audiosToCopy[i],
        );
      }
    }

    // Clean up cache files after they have been saved to the note directory
    if (imagesToCopy != null || videosToCopy != null || audiosToCopy != null) {
      final allMediaPaths = <String>[];
      if (imagesToCopy != null) allMediaPaths.addAll(imagesToCopy);
      if (videosToCopy != null) allMediaPaths.addAll(videosToCopy);
      if (audiosToCopy != null) allMediaPaths.addAll(audiosToCopy);

      await MediaUtil.cleanupCacheFiles(allMediaPaths);
    }

    return noteId;
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    return await _noteService.getAllNotes();
  }

  /// Get all notes including deleted ones for sync purposes
  Future<List<Note>> getAllNotesForSync() async {
    return await _noteService.getAllNotesForSync();
  }

  // Get a note by ID
  Future<Note?> getNoteById(String id) async {
    return await _noteService.getNoteById(id);
  }

  // Get all media paths for a note
  Future<Map<String, List<String>>> getNoteMedia(String noteId) async {
    return await MediaUtil.getNoteMedia(noteId);
  }

  // Update a note with optional media additions
  Future<void> updateNote({
    required String id,
    String? content,
    List<String>? newImagesToCopy, // New images to add to the note
    List<String>? newVideosToCopy, // New videos to add to the note
    List<String>? newAudiosToCopy, // New audios to add to the note
    String? notebookId,
    DateTime? updateTime, // Allow specifying updateTime from cloud
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
        final newImageName = MediaUtil.generateImageFilename(imagePath);
        await MediaUtil.saveImageToNote(id, newImageName, imagePath);
        newImageNames.add(newImageName);
      }
      updatedImageNames = [...existingNote.images, ...newImageNames];
    }

    if (newVideosToCopy != null) {
      List<String> newVideoNames = [];
      for (final videoPath in newVideosToCopy) {
        final newVideoName = MediaUtil.generateVideoFilename(videoPath);
        await MediaUtil.saveVideoToNote(id, newVideoName, videoPath);
        newVideoNames.add(newVideoName);
      }
      updatedVideoNames = [...existingNote.videos, ...newVideoNames];
    }

    if (newAudiosToCopy != null) {
      List<String> newAudioNames = [];
      for (final audioPath in newAudiosToCopy) {
        final newAudioName = MediaUtil.generateAudioFilename(audioPath);
        await MediaUtil.saveAudioToNote(id, newAudioName, audioPath);
        newAudioNames.add(newAudioName);
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
      updateTime: updateTime,
    );

    // Clean up cache files after they have been saved to the note directory
    if (newImagesToCopy != null ||
        newVideosToCopy != null ||
        newAudiosToCopy != null) {
      final allMediaPaths = <String>[];
      if (newImagesToCopy != null) allMediaPaths.addAll(newImagesToCopy);
      if (newVideosToCopy != null) allMediaPaths.addAll(newVideosToCopy);
      if (newAudiosToCopy != null) allMediaPaths.addAll(newAudiosToCopy);

      await MediaUtil.cleanupCacheFiles(allMediaPaths);
    }
  }

  // Update the media of a note (for deletion or replacement)
  Future<void> updateNoteMedia({
    required String id,
    List<String>? imageNames, // New list of image names
    List<String>? videoNames, // New list of video names
    List<String>? audioNames, // New list of audio names
    String? noteContent, // Content to update with (optional)
    String? notebookId, // Notebook ID to update with (optional)
  }) async {
    final existingNote = await _noteService.getNoteById(id);
    if (existingNote == null) {
      throw Exception('Note with id $id does not exist');
    }

    // Get current media names
    List<String> updatedImageNames = imageNames ?? existingNote.images;
    List<String> updatedVideoNames = videoNames ?? existingNote.videos;
    List<String> updatedAudioNames = audioNames ?? existingNote.audios;

    // Update the note with the new media lists
    await _noteService.updateNote(
      id: id,
      content: noteContent ?? existingNote.content,
      imageName: updatedImageNames,
      audioName: updatedAudioNames,
      videoName: updatedVideoNames,
      notebookId: notebookId ?? existingNote.notebookId,
    );

    // Clean up media files that are no longer associated with this note
    await _cleanupOrphanedMedia(
      id,
      existingNote,
      updatedImageNames,
      updatedVideoNames,
      updatedAudioNames,
    );
  }

  // Helper method to clean up media files that are no longer associated with a note
  Future<void> _cleanupOrphanedMedia(
    String noteId,
    Note existingNote,
    List<String> newImageNames,
    List<String> newVideoNames,
    List<String> newAudioNames,
  ) async {
    // Get a list of files to delete by comparing with old list
    List<String> deletedImages = existingNote.images
        .where((name) => !newImageNames.contains(name))
        .toList();
    List<String> deletedVideos = existingNote.videos
        .where((name) => !newVideoNames.contains(name))
        .toList();
    List<String> deletedAudios = existingNote.audios
        .where((name) => !newAudioNames.contains(name))
        .toList();

    // Delete the media files that are no longer needed
    for (String imageName in deletedImages) {
      await MediaUtil.deleteImageFromMediaService(noteId, imageName);
    }

    for (String videoName in deletedVideos) {
      await MediaUtil.deleteVideoFromMediaService(noteId, videoName);
    }

    for (String audioName in deletedAudios) {
      await MediaUtil.deleteAudioFromMediaService(noteId, audioName);
    }
  }

  // Delete a note and its associated media
  // Note: This is a soft delete - we update the isDeleted flag and updateTime to reflect this modification
  Future<void> deleteNote(String id) async {
    // Get the existing note before deletion
    Note? existingNote = await _noteService.getNoteById(id);
    if (existingNote != null) {
      // Update the note's updateTime to reflect this deletion as a modification
      await _noteService.updateNote(
        id: id,
        content: existingNote.content,
        updateTime:
            DateTime.now(), // Update the modification time when deleting
        notebookId: existingNote.notebookId,
      );
    }

    // Delete all associated media files
    await MediaUtil.deleteNoteMediaFromMediaService(id);

    // Then mark the note as deleted (soft delete with is_deleted=true)
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

  // Get notes by date
  Future<List<Note>> getNotesByDate(DateTime date) async {
    return await _noteService.getNotesByDate(date);
  }

  // Get all unique tags
  Future<List<String>> getAllTags() async {
    return await _noteService.getAllTags();
  }

  /// Save a note with all cloud data preserved (ID, createTime, updateTime)
  /// This method is specifically for sync operations where we need to maintain cloud data integrity
  Future<void> saveNoteWithCloudData({
    required String id,
    required String content,
    required DateTime createTime,
    DateTime? updateTime,
    List<String>? images,
    List<String>? videos,
    List<String>? audios,
    String? notebookId,
  }) async {
    // Create or update the note in the database with all cloud data preserved
    final note = Note(
      id: id,
      content: content,
      createTime: createTime,
      updateTime: updateTime,
      notebookId: notebookId,
      images: images ?? [],
      videos: videos ?? [],
      audios: audios ?? [],
    );

    final service = Get.find<NoteService>();
    // Ensure the service is initialized before using it
    await service.init();
    await service.saveNote(note);
  }

  // Close the services
  Future<void> close() async {
    await _noteService.close();
  }
}