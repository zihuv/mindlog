import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindlog/data/services/media_service.dart';
import 'package:mindlog/utils/log_util.dart';
import 'package:mindlog/services/filename_utility_service.dart';

enum ImageQuality { low, standard, high, original }

class ImageCompressionService {
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
      default:
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

    // Get media service instance
    final mediaService = MediaService();

    // Generate new filename with UUID v7 if no filename provided
    final newFileName = fileName ?? FilenameUtilityService.generateImageFilename(compressedFile.path);

    // Save the compressed file to the note's media directory
    final savedPath = await mediaService.saveImage(
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