import 'package:uuid/uuid.dart';

class FilenameUtilityService {
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
}