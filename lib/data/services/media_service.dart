import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class MediaService {
  static const String _imagesDirName = 'images';
  static const String _videosDirName = 'videos';
  static const String _audiosDirName = 'audios';

  Future<Directory> _getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<Directory> _getAppCacheDirectory() async {
    final directory = await getApplicationCacheDirectory();
    return directory;
  }

  // Check if the provided path is in the cache directory
  Future<bool> _isCachePath(String filePath) async {
    final cacheDir = await _getAppCacheDirectory();
    final cachePath = cacheDir.path;
    return filePath.startsWith(cachePath);
  }

  Future<Directory> _getNoteDirectory(String noteId, String mediaType) async {
    final appDir = await _getAppDirectory();
    final noteDir = Directory(path.join(appDir.path, mediaType, noteId));

    // Create directory if it doesn't exist
    if (!await noteDir.exists()) {
      await noteDir.create(recursive: true);
    }

    return noteDir;
  }

  // Save image file to the appropriate note directory
  Future<String> saveImage(
    String noteId,
    String fileName,
    String sourcePath,
  ) async {
    final noteDir = await _getNoteDirectory(noteId, _imagesDirName);
    final destinationPath = path.join(noteDir.path, fileName);

    // Check if the source file is in the cache directory
    bool isCachePath = await _isCachePath(sourcePath);
    print('Saving image: sourcePath=$sourcePath, isCachePath=$isCachePath, destinationPath=$destinationPath');

    if (isCachePath) {
      // If the source file is in cache, copy it from the cache to the note directory
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      print('Copied from cache to storage: ${sourceFile.path} -> ${destinationFile.path}');
      return destinationFile.path;
    } else {
      // If the source file is not in cache, it might be a file that already exists in our storage
      // We should still copy it to the correct location for this note
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      print('Copied from source to storage: ${sourceFile.path} -> ${destinationFile.path}');
      return destinationFile.path;
    }
  }

  // Save video file to the appropriate note directory
  Future<String> saveVideo(
    String noteId,
    String fileName,
    String sourcePath,
  ) async {
    final noteDir = await _getNoteDirectory(noteId, _videosDirName);
    final destinationPath = path.join(noteDir.path, fileName);

    // Check if the source file is in the cache directory
    bool isCachePath = await _isCachePath(sourcePath);
    print('Saving video: sourcePath=$sourcePath, isCachePath=$isCachePath, destinationPath=$destinationPath');

    if (isCachePath) {
      // If the source file is in cache, copy it from the cache to the note directory
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      print('Copied from cache to storage: ${sourceFile.path} -> ${destinationFile.path}');
      return destinationFile.path;
    } else {
      // If the source file is not in cache, it might be a file that already exists in our storage
      // We should still copy it to the correct location for this note
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      print('Copied from source to storage: ${sourceFile.path} -> ${destinationFile.path}');
      return destinationFile.path;
    }
  }

  // Save audio file to the appropriate note directory
  Future<String> saveAudio(
    String noteId,
    String fileName,
    String sourcePath,
  ) async {
    final noteDir = await _getNoteDirectory(noteId, _audiosDirName);
    final destinationPath = path.join(noteDir.path, fileName);

    // Check if the source file is in the cache directory
    bool isCachePath = await _isCachePath(sourcePath);
    print('Saving audio: sourcePath=$sourcePath, isCachePath=$isCachePath, destinationPath=$destinationPath');

    if (isCachePath) {
      // If the source file is in cache, copy it from the cache to the note directory
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      print('Copied from cache to storage: ${sourceFile.path} -> ${destinationFile.path}');
      return destinationFile.path;
    } else {
      // If the source file is not in cache, it might be a file that already exists in our storage
      // We should still copy it to the correct location for this note
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      print('Copied from source to storage: ${sourceFile.path} -> ${destinationFile.path}');
      return destinationFile.path;
    }
  }

  // Get all image paths for a specific note
  Future<List<String>> getNoteImages(String noteId) async {
    final noteDir = await _getNoteDirectory(noteId, _imagesDirName);
    if (!await noteDir.exists()) {
      return [];
    }

    final files = await noteDir.list().toList();
    return files.whereType<File>().map((file) => file.path).toList();
  }

  // Get all video paths for a specific note
  Future<List<String>> getNoteVideos(String noteId) async {
    final noteDir = await _getNoteDirectory(noteId, _videosDirName);
    if (!await noteDir.exists()) {
      return [];
    }

    final files = await noteDir.list().toList();
    return files.whereType<File>().map((file) => file.path).toList();
  }

  // Get all audio paths for a specific note
  Future<List<String>> getNoteAudios(String noteId) async {
    final noteDir = await _getNoteDirectory(noteId, _audiosDirName);
    if (!await noteDir.exists()) {
      return [];
    }

    final files = await noteDir.list().toList();
    return files.whereType<File>().map((file) => file.path).toList();
  }

  // Get all media paths for a specific note
  Future<Map<String, List<String>>> getNoteMedia(String noteId) async {
    final images = await getNoteImages(noteId);
    final videos = await getNoteVideos(noteId);
    final audios = await getNoteAudios(noteId);

    return {'images': images, 'videos': videos, 'audios': audios};
  }

  // Delete a specific media file
  Future<void> deleteMediaFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Delete all media for a specific note
  Future<void> deleteNoteMedia(String noteId) async {
    // Delete images directory for the note
    final imagesDir = await _getNoteDirectory(noteId, _imagesDirName);
    if (await imagesDir.exists()) {
      await imagesDir.delete(recursive: true);
    }

    // Delete videos directory for the note
    final videosDir = await _getNoteDirectory(noteId, _videosDirName);
    if (await videosDir.exists()) {
      await videosDir.delete(recursive: true);
    }

    // Delete audios directory for the note
    final audiosDir = await _getNoteDirectory(noteId, _audiosDirName);
    if (await audiosDir.exists()) {
      await audiosDir.delete(recursive: true);
    }
  }

  // Get the full path for a media file in a specific note directory
  Future<String> getMediaPath(
    String noteId,
    String mediaType,
    String fileName,
  ) async {
    final noteDir = await _getNoteDirectory(noteId, mediaType);
    return path.join(noteDir.path, fileName);
  }

  // Check if a media file exists
  Future<bool> mediaFileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  // Get the root directory for all media
  Future<Directory> getMediaRootDirectory() async {
    final appDir = await _getAppDirectory();
    return Directory(path.join(appDir.path, 'media'));
  }

  // Get storage usage for all media
  Future<int> getMediaStorageUsage() async {
    final rootDir = await getMediaRootDirectory();
    if (!await rootDir.exists()) {
      return 0;
    }

    int totalSize = 0;
    await for (final entity in rootDir.list(recursive: true)) {
      if (entity is File) {
        try {
          final stat = await entity.stat();
          totalSize += stat.size;
        } catch (e) {
          // Skip if we can't read the file stats
        }
      }
    }
    return totalSize;
  }

  // Clean up cache files after they have been properly saved to the note directory
  Future<void> cleanupCacheFiles(List<String> cacheFilePaths) async {
    for (final cachePath in cacheFilePaths) {
      final isCachePath = await _isCachePath(cachePath);
      if (isCachePath) {
        final file = File(cachePath);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (e) {
            // If we can't delete the file, log the error but continue
            print('Could not delete cache file $cachePath: $e');
          }
        }
      }
    }
  }
}
