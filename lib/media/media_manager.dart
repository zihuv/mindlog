import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MediaManager {
  static const String _imagesDir = 'images';
  static const String _videosDir = 'videos';
  static const String _audioDir = 'audio';

  // Get the base directory for storing media related to a specific note
  static Future<Directory> _getNoteMediaDirectory(String noteId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final noteMediaDir = Directory('${appDir.path}/media/$noteId');
    await noteMediaDir.create(recursive: true);
    return noteMediaDir;
  }

  // Get directory for a specific media type within a note's directory
  static Future<Directory> _getNoteMediaTypeDirectory(
    String noteId,
    String mediaType,
  ) async {
    final noteDir = await _getNoteMediaDirectory(noteId);
    final typeDir = Directory(path.join(noteDir.path, mediaType));
    await typeDir.create(recursive: true);
    return typeDir;
  }

  // Save an image file for a specific note
  Future<String> saveImage(
    String noteId,
    File imageFile, {
    String? fileName,
  }) async {
    final imagesDir = await _getNoteMediaTypeDirectory(noteId, _imagesDir);
    final newFileName =
        fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imagePath = path.join(imagesDir.path, newFileName);
    final newFile = await imageFile.copy(imagePath);
    return newFile.path;
  }

  // Save a video file for a specific note
  Future<String> saveVideo(
    String noteId,
    File videoFile, {
    String? fileName,
  }) async {
    final videosDir = await _getNoteMediaTypeDirectory(noteId, _videosDir);
    final newFileName =
        fileName ?? '${DateTime.now().millisecondsSinceEpoch}.mp4';
    final videoPath = path.join(videosDir.path, newFileName);
    final newFile = await videoFile.copy(videoPath);
    return newFile.path;
  }

  // Save an audio file for a specific note
  Future<String> saveAudio(
    String noteId,
    File audioFile, {
    String? fileName,
  }) async {
    final audioDir = await _getNoteMediaTypeDirectory(noteId, _audioDir);
    final newFileName =
        fileName ?? '${DateTime.now().millisecondsSinceEpoch}.mp3';
    final audioPath = path.join(audioDir.path, newFileName);
    final newFile = await audioFile.copy(audioPath);
    return newFile.path;
  }

  // Get the path to an image for a specific note
  Future<String?> getImagePath(String noteId, String imageName) async {
    final imagesDir = await _getNoteMediaTypeDirectory(noteId, _imagesDir);
    final imagePath = path.join(imagesDir.path, imageName);
    final imageFile = File(imagePath);
    return imageFile.existsSync() ? imageFile.path : null;
  }

  // Get the path to a video for a specific note
  Future<String?> getVideoPath(String noteId, String videoName) async {
    final videosDir = await _getNoteMediaTypeDirectory(noteId, _videosDir);
    final videoPath = path.join(videosDir.path, videoName);
    final videoFile = File(videoPath);
    return videoFile.existsSync() ? videoFile.path : null;
  }

  // Get the path to an audio file for a specific note
  Future<String?> getAudioPath(String noteId, String audioName) async {
    final audioDir = await _getNoteMediaTypeDirectory(noteId, _audioDir);
    final audioPath = path.join(audioDir.path, audioName);
    final audioFile = File(audioPath);
    return audioFile.existsSync() ? audioFile.path : null;
  }

  // Get a list of all image paths for a specific note
  Future<List<String>> getNoteImages(String noteId) async {
    final imagesDir = await _getNoteMediaTypeDirectory(noteId, _imagesDir);
    if (!await imagesDir.exists()) return [];

    final List<File> imageFiles = [];
    await for (final entity in imagesDir.list()) {
      if (entity is File) {
        imageFiles.add(entity);
      }
    }
    return imageFiles.map((file) => file.path).toList();
  }

  // Get a list of all video paths for a specific note
  Future<List<String>> getNoteVideos(String noteId) async {
    final videosDir = await _getNoteMediaTypeDirectory(noteId, _videosDir);
    if (!await videosDir.exists()) return [];

    final List<File> videoFiles = [];
    await for (final entity in videosDir.list()) {
      if (entity is File) {
        videoFiles.add(entity);
      }
    }
    return videoFiles.map((file) => file.path).toList();
  }

  // Get a list of all audio paths for a specific note
  Future<List<String>> getNoteAudio(String noteId) async {
    final audioDir = await _getNoteMediaTypeDirectory(noteId, _audioDir);
    if (!await audioDir.exists()) return [];

    final List<File> audioFiles = [];
    await for (final entity in audioDir.list()) {
      if (entity is File) {
        audioFiles.add(entity);
      }
    }
    return audioFiles.map((file) => file.path).toList();
  }

  // Delete a specific image for a note
  Future<void> deleteImage(String noteId, String imageName) async {
    final imagePath = await getImagePath(noteId, imageName);
    if (imagePath != null) {
      final imageFile = File(imagePath);
      await imageFile.delete();
    }
  }

  // Delete a specific video for a note
  Future<void> deleteVideo(String noteId, String videoName) async {
    final videoPath = await getVideoPath(noteId, videoName);
    if (videoPath != null) {
      final videoFile = File(videoPath);
      await videoFile.delete();
    }
  }

  // Delete a specific audio file for a note
  Future<void> deleteAudio(String noteId, String audioName) async {
    final audioPath = await getAudioPath(noteId, audioName);
    if (audioPath != null) {
      final audioFile = File(audioPath);
      await audioFile.delete();
    }
  }

  // Delete all media for a specific note (useful when completely deleting a note)
  Future<void> deleteNoteMedia(String noteId) async {
    final noteDir = await _getNoteMediaDirectory(noteId);
    if (await noteDir.exists()) {
      await noteDir.delete(recursive: true);
    }
  }

  // Get the base URL for a note's media directory
  Future<String> getNoteMediaBasePath(String noteId) async {
    final noteDir = await _getNoteMediaDirectory(noteId);
    return noteDir.path;
  }
}
