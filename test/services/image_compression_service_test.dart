import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindlog/utils/media_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageCompressionService Tests', () {
    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({
        'image_compression_quality': 'standard',
        'image_compression_enabled': true,
      });
    });

    test('getImageQuality returns correct quality level', () async {
      // Test default value (should be 'standard')
      ImageQuality quality = await MediaUtil.getImageQuality();
      expect(quality, equals(ImageQuality.standard));

      // Test 'low' quality
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_compression_quality', 'low');
      quality = await MediaUtil.getImageQuality();
      expect(quality, equals(ImageQuality.low));

      // Test 'high' quality
      await prefs.setString('image_compression_quality', 'high');
      quality = await MediaUtil.getImageQuality();
      expect(quality, equals(ImageQuality.high));

      // Test 'original' quality
      await prefs.setString('image_compression_quality', 'original');
      quality = await MediaUtil.getImageQuality();
      expect(quality, equals(ImageQuality.original));
    });

    test('isCompressionEnabled returns correct value', () async {
      // Test default value (should be true)
      bool enabled = await MediaUtil.isCompressionEnabled();
      expect(enabled, isTrue);

      // Test when disabled
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('image_compression_enabled', false);
      enabled = await MediaUtil.isCompressionEnabled();
      expect(enabled, isFalse);
    });

    test('compressImage with compression disabled returns original file', () async {
      // Disable compression
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('image_compression_enabled', false);

      // Create a temporary image file for testing
      final tempDir = await getTemporaryDirectory();
      final testImageFile = File(path.join(tempDir.path, 'test_image.jpg'));
      // Write minimal valid JPEG data (just a placeholder for test)
      await testImageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00]);

      // Compress image (should return original since compression is disabled)
      final resultFile = await MediaUtil.compressImage(testImageFile);

      // Should return the original file when compression is disabled
      expect(resultFile.path, equals(testImageFile.path));

      // Clean up
      await testImageFile.delete();
    });

    test('compressImage with original quality returns original file', () async {
      // Set quality to original
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_compression_quality', 'original');

      // Create a temporary image file for testing
      final tempDir = await getTemporaryDirectory();
      final testImageFile = File(path.join(tempDir.path, 'test_image.jpg'));
      // Write minimal valid JPEG data (just a placeholder for test)
      await testImageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00]);

      // Compress image (should return original since quality is original)
      final resultFile = await MediaUtil.compressImage(testImageFile);

      // Should return the original file when original quality is selected
      expect(resultFile.path, equals(testImageFile.path));

      // Clean up
      await testImageFile.delete();
    });

    test('compressAndSaveImage method exists', () {
      // The compressAndSaveImage method is a public API method
      // We're testing that it exists in the class
      expect(MediaUtil.compressAndSaveImage, isNotNull);
    });
  });
}