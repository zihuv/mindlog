import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindlog/utils/log_util.dart';

enum ImageQuality { low, standard, high, original }

class MediaUtil {
  static const String _imagesDir = 'images';
  static const String _videosDir = 'videos';
  static const String _audioDir = 'audio';
  
  // MediaService constants
  static const String _imagesDirName = 'images';
  static const String _videosDirName = 'videos';
  static const String _audiosDirName = 'audios';

  // FilenameUtilityService functionality
  // Generate a UUID v7 based filename with the format image-{UUID}.{extension}
  static String generateImageFilename(String originalPath) {
    final uuid = const Uuid().v7();
    final fileExtension = _getFileExtension(originalPath);
    return 'image-$uuid.$fileExtension';
  }

  // Generate a UUID v7 based filename with the format video-{UUID}.{extension}
  static String generateVideoFilename(String originalPath) {
    final uuid = const Uuid().v7();
    final fileExtension = _getFileExtension(originalPath);
    return 'video-$uuid.$fileExtension';
  }

  // Generate a UUID v7 based filename with the format audio-{UUID}.{extension}
  static String generateAudioFilename(String originalPath) {
    final uuid = const Uuid().v7();
    final fileExtension = _getFileExtension(originalPath);
    return 'audio-$uuid.$fileExtension';
  }

  // Helper method to get file extension
  static String _getFileExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    // Ensure we return a valid image extension
    if (['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'mp4', 'mov', 'avi', 'mkv', 'mp3', 'wav', 'm4a'].contains(extension)) {
      return extension;
    }
    // Default to jpg if extension is not recognized for images
    return 'jpg';
  }

  // MediaManager functionality - Directory management
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

  // MediaService functionality - Directory management
  static Future<Directory> _getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  static Future<Directory> _getAppCacheDirectory() async {
    final directory = await getApplicationCacheDirectory();
    return directory;
  }

  // Check if the provided path is in the cache directory
  static Future<bool> _isCachePath(String filePath) async {
    final cacheDir = await _getAppCacheDirectory();
    final cachePath = cacheDir.path;
    return filePath.startsWith(cachePath);
  }

  static Future<Directory> _getNoteDirectory(String noteId, String mediaType) async {
    final appDir = await _getAppDirectory();
    final noteDir = Directory(path.join(appDir.path, mediaType, noteId));

    // Create directory if it doesn't exist
    if (!await noteDir.exists()) {
      await noteDir.create(recursive: true);
    }

    return noteDir;
  }

  // MediaManager functionality - Save methods
  // Save an image file for a specific note
  static Future<String> saveImage(
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
  static Future<String> saveVideo(
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
  static Future<String> saveAudio(
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

  // MediaService functionality - Save methods
  // Save image file to the appropriate note directory
  static Future<String> saveImageToNote(
    String noteId,
    String fileName,
    String sourcePath,
  ) async {
    final noteDir = await _getNoteDirectory(noteId, _imagesDirName);
    final destinationPath = path.join(noteDir.path, fileName);

    // Check if the source file is in the cache directory
    bool isCachePath = await _isCachePath(sourcePath);
    logger.debug(
      'Saving image: sourcePath=$sourcePath, isCachePath=$isCachePath, destinationPath=$destinationPath',
    );

    if (isCachePath) {
      // If the source file is in cache, copy it from the cache to the note directory
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      logger.debug(
        'Copied from cache to storage: ${sourceFile.path} -> ${destinationFile.path}',
      );
      return destinationFile.path;
    } else {
      // If the source file is not in cache, it might be a file that already exists in our storage
      // We should still copy it to the correct location for this note
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      logger.debug(
        'Copied from source to storage: ${sourceFile.path} -> ${destinationFile.path}',
      );
      return destinationFile.path;
    }
  }

  // Save video file to the appropriate note directory
  static Future<String> saveVideoToNote(
    String noteId,
    String fileName,
    String sourcePath,
  ) async {
    final noteDir = await _getNoteDirectory(noteId, _videosDirName);
    final destinationPath = path.join(noteDir.path, fileName);

    // Check if the source file is in the cache directory
    bool isCachePath = await _isCachePath(sourcePath);
    logger.debug(
      'Saving video: sourcePath=$sourcePath, isCachePath=$isCachePath, destinationPath=$destinationPath',
    );

    if (isCachePath) {
      // If the source file is in cache, copy it from the cache to the note directory
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      logger.debug(
        'Copied from cache to storage: ${sourceFile.path} -> ${destinationFile.path}',
      );
      return destinationFile.path;
    } else {
      // If the source file is not in cache, it might be a file that already exists in our storage
      // We should still copy it to the correct location for this note
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      logger.debug(
        'Copied from source to storage: ${sourceFile.path} -> ${destinationFile.path}',
      );
      return destinationFile.path;
    }
  }

  // Save audio file to the appropriate note directory
  static Future<String> saveAudioToNote(
    String noteId,
    String fileName,
    String sourcePath,
  ) async {
    final noteDir = await _getNoteDirectory(noteId, _audiosDirName);
    final destinationPath = path.join(noteDir.path, fileName);

    // Check if the source file is in the cache directory
    bool isCachePath = await _isCachePath(sourcePath);
    logger.debug(
      'Saving audio: sourcePath=$sourcePath, isCachePath=$isCachePath, destinationPath=$destinationPath',
    );

    if (isCachePath) {
      // If the source file is in cache, copy it from the cache to the note directory
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      logger.debug(
        'Copied from cache to storage: ${sourceFile.path} -> ${destinationFile.path}',
      );
      return destinationFile.path;
    } else {
      // If the source file is not in cache, it might be a file that already exists in our storage
      // We should still copy it to the correct location for this note
      final sourceFile = File(sourcePath);
      final destinationFile = await sourceFile.copy(destinationPath);
      logger.debug(
        'Copied from source to storage: ${sourceFile.path} -> ${destinationFile.path}',
      );
      return destinationFile.path;
    }
  }

  // MediaManager functionality - Get methods
  // Get the path to an image for a specific note
  static Future<String?> getImagePath(String noteId, String imageName) async {
    final imagesDir = await _getNoteMediaTypeDirectory(noteId, _imagesDir);
    final imagePath = path.join(imagesDir.path, imageName);
    final imageFile = File(imagePath);
    return imageFile.existsSync() ? imageFile.path : null;
  }

  // Get the path to a video for a specific note
  static Future<String?> getVideoPath(String noteId, String videoName) async {
    final videosDir = await _getNoteMediaTypeDirectory(noteId, _videosDir);
    final videoPath = path.join(videosDir.path, videoName);
    final videoFile = File(videoPath);
    return videoFile.existsSync() ? videoFile.path : null;
  }

  // Get the path to an audio file for a specific note
  static Future<String?> getAudioPath(String noteId, String audioName) async {
    final audioDir = await _getNoteMediaTypeDirectory(noteId, _audioDir);
    final audioPath = path.join(audioDir.path, audioName);
    final audioFile = File(audioPath);
    return audioFile.existsSync() ? audioFile.path : null;
  }

  // Get a list of all image paths for a specific note
  static Future<List<String>> getNoteImages(String noteId) async {
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
  static Future<List<String>> getNoteVideos(String noteId) async {
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
  static Future<List<String>> getNoteAudio(String noteId) async {
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

  // MediaService functionality - Get methods
  // Get all image paths for a specific note
  static Future<List<String>> getNoteImagesFromMediaService(String noteId) async {
    final noteDir = await _getNoteDirectory(noteId, _imagesDirName);
    if (!await noteDir.exists()) {
      return [];
    }

    final files = await noteDir.list().toList();
    return files.whereType<File>().map((file) => file.path).toList();
  }

  // Get all video paths for a specific note
  static Future<List<String>> getNoteVideosFromMediaService(String noteId) async {
    final noteDir = await _getNoteDirectory(noteId, _videosDirName);
    if (!await noteDir.exists()) {
      return [];
    }

    final files = await noteDir.list().toList();
    return files.whereType<File>().map((file) => file.path).toList();
  }

  // Get all audio paths for a specific note
  static Future<List<String>> getNoteAudiosFromMediaService(String noteId) async {
    final noteDir = await _getNoteDirectory(noteId, _audiosDirName);
    if (!await noteDir.exists()) {
      return [];
    }

    final files = await noteDir.list().toList();
    return files.whereType<File>().map((file) => file.path).toList();
  }

  // Get all media paths for a specific note
  static Future<Map<String, List<String>>> getNoteMedia(String noteId) async {
    final images = await getNoteImagesFromMediaService(noteId);
    final videos = await getNoteVideosFromMediaService(noteId);
    final audios = await getNoteAudiosFromMediaService(noteId);

    return {'images': images, 'videos': videos, 'audios': audios};
  }

  // MediaManager functionality - Delete methods
  // Delete a specific image for a note
  static Future<void> deleteImage(String noteId, String imageName) async {
    final imagePath = await getImagePath(noteId, imageName);
    if (imagePath != null) {
      final imageFile = File(imagePath);
      await imageFile.delete();
    }
  }

  // Delete a specific video for a note
  static Future<void> deleteVideo(String noteId, String videoName) async {
    final videoPath = await getVideoPath(noteId, videoName);
    if (videoPath != null) {
      final videoFile = File(videoPath);
      await videoFile.delete();
    }
  }

  // Delete a specific audio file for a note
  static Future<void> deleteAudio(String noteId, String audioName) async {
    final audioPath = await getAudioPath(noteId, audioName);
    if (audioPath != null) {
      final audioFile = File(audioPath);
      await audioFile.delete();
    }
  }

  // Delete all media for a specific note (useful when completely deleting a note)
  static Future<void> deleteNoteMedia(String noteId) async {
    final noteDir = await _getNoteMediaDirectory(noteId);
    if (await noteDir.exists()) {
      await noteDir.delete(recursive: true);
    }
  }

  // MediaService functionality - Delete methods
  // Delete a specific media file
  static Future<void> deleteMediaFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Delete a specific image file for a note
  static Future<void> deleteImageFromMediaService(String noteId, String imageName) async {
    final imagePath = await getMediaPath(noteId, _imagesDirName, imageName);
    await deleteMediaFile(imagePath);
  }

  // Delete a specific video file for a note
  static Future<void> deleteVideoFromMediaService(String noteId, String videoName) async {
    final videoPath = await getMediaPath(noteId, _videosDirName, videoName);
    await deleteMediaFile(videoPath);
  }

  // Delete a specific audio file for a note
  static Future<void> deleteAudioFromMediaService(String noteId, String audioName) async {
    final audioPath = await getMediaPath(noteId, _audiosDirName, audioName);
    await deleteMediaFile(audioPath);
  }

  // Delete all media for a specific note
  static Future<void> deleteNoteMediaFromMediaService(String noteId) async {
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
  static Future<String> getMediaPath(
    String noteId,
    String mediaType,
    String fileName,
  ) async {
    final noteDir = await _getNoteDirectory(noteId, mediaType);
    return path.join(noteDir.path, fileName);
  }

  // Check if a media file exists
  static Future<bool> mediaFileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  // Get the base URL for a note's media directory (from MediaManager)
  static Future<String> getNoteMediaBasePath(String noteId) async {
    final noteDir = await _getNoteMediaDirectory(noteId);
    return noteDir.path;
  }

  // Get the root directory for all media
  static Future<Directory> getMediaRootDirectory() async {
    final appDir = await _getAppDirectory();
    return Directory(path.join(appDir.path, 'media'));
  }

  // Get storage usage for all media
  static Future<int> getMediaStorageUsage() async {
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
  static Future<void> cleanupCacheFiles(List<String> cacheFilePaths) async {
    for (final cachePath in cacheFilePaths) {
      final isCachePath = await _isCachePath(cachePath);
      if (isCachePath) {
        final file = File(cachePath);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (e) {
            // If we can't delete the file, log the error but continue
            logger.warning('Could not delete cache file $cachePath: $e');
          }
        }
      }
    }
  }

  // ImageCompressionService functionality
  static const int _lowQuality = 40; // 40% quality for low
  static const int _standardQuality = 70; // 70% quality for standard
  static const int _highQuality = 90; // 90% quality for high
  static const int _originalQuality =
      100; // 100% quality for original (no compression)

  // Get the quality setting from shared preferences
  static Future<ImageQuality> getImageQuality() async {
    final prefs = await SharedPreferences.getInstance();
    final qualityString =
        prefs.getString('image_compression_quality') ?? 'standard';

    switch (qualityString) {
      case 'low':
        return ImageQuality.low;
      case 'high':
        return ImageQuality.high;
      case 'original':
        return ImageQuality.original;
      case 'standard':
        return ImageQuality.standard;
      default:
        return ImageQuality.standard;
    }
  }

  // Check if image compression is enabled
  static Future<bool> isCompressionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('image_compression_enabled') ?? true;
  }

  // Get the quality value based on the selected quality level
  static int _getQualityValue(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return _lowQuality;
      case ImageQuality.high:
        return _highQuality;
      case ImageQuality.original:
        return _originalQuality;
      case ImageQuality.standard:
        return _standardQuality;
    }
  }

  // Compress an image file and return the compressed file
  static Future<File> compressImage(File originalFile) async {
    final compressionEnabled = await isCompressionEnabled();
    if (!compressionEnabled) {
      // If compression is disabled, return the original file
      logger.debug('Image compression is disabled, returning original file');
      return originalFile;
    }

    final quality = await getImageQuality();
    final qualityValue = _getQualityValue(quality);

    // 获取原始文件大小
    final originalFileSize = await originalFile.length();
    logger.debug('Original image file size: ${originalFileSize / 1024} KB');

    if (qualityValue >= _originalQuality) {
      // If original quality is selected, return the original file
      logger.debug('Original quality selected, returning original file');
      return originalFile;
    }

    // Get temporary directory for the compressed image
    final tempDir = await getTemporaryDirectory();
    final compressedPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${originalFile.path.split('/').last}';
    final compressedFile = File(compressedPath);

    // Compress the image with new dimensions
    await FlutterImageCompress.compressAndGetFile(
      originalFile.absolute.path,
      compressedFile.absolute.path,
      quality: qualityValue,
      minWidth: 1920,
      minHeight: 1080,
    );

    // If compression didn't create a file or it's larger than original, return original
    if (!await compressedFile.exists()) {
      logger.warning(
        'Compressed file was not created, returning original file',
      );
      return originalFile;
    }

    final compressedFileSize = await compressedFile.length();
    logger.info(
      'Image compressed: '
      '${originalFileSize ~/ 1024} KB -> ${compressedFileSize ~/ 1024} KB '
      '(${(compressedFileSize / originalFileSize * 100).toStringAsFixed(2)}% of original, '
      'saved ${(originalFileSize - compressedFileSize) ~/ 1024} KB)',
    );

    if (compressedFileSize >= originalFileSize) {
      logger.info(
        'Compressed file is larger than or equal to original, returning original file',
      );
      return originalFile;
    }

    return compressedFile;
  }

  // Compress and save image from cache to the document directory
  static Future<String> compressAndSaveImage(
    String noteId,
    File imageFile,
    String? fileName,
  ) async {
    // First compress the image
    final compressedFile = await compressImage(imageFile);

    // Generate new filename with UUID v7 if no filename provided
    final newFileName = fileName ?? generateImageFilename(compressedFile.path);

    // Save the compressed file to the note's media directory
    final savedPath = await saveImageToNote(
      noteId,
      newFileName,
      compressedFile.path,
    );

    // If we created a temporary compressed file (not the original), delete it
    if (compressedFile.path != imageFile.path) {
      try {
        await compressedFile.delete();
        logger.debug('Temporary compressed file deleted');
      } catch (e) {
        // If we can't delete the temp file, just log it
        logger.warning('Could not delete temporary compressed file: $e');
      }
    }

    logger.debug('Image saved to: $savedPath');
    return savedPath;
  }
}