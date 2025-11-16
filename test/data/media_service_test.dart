import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/data/services/media_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MediaService mediaService;

  setUp(() async {
    mediaService = MediaService();
  });

  group('MediaService Tests', () {
    test('Create note directories through public API', () async {
      final noteId = 'test-note-id-media';
      final tempDir = await getTemporaryDirectory();

      // Create test files
      final testImageFile = File(path.join(tempDir.path, 'test_image.jpg'));
      await testImageFile.writeAsBytes([0, 1, 2, 3, 4]); // Write dummy data

      final testVideoFile = File(path.join(tempDir.path, 'test_video.mp4'));
      await testVideoFile.writeAsBytes([5, 6, 7, 8, 9]);

      final testAudioFile = File(path.join(tempDir.path, 'test_audio.mp3'));
      await testAudioFile.writeAsBytes([10, 11, 12, 13, 14]);

      // Test creating image directory by saving an image
      await mediaService.saveImage(
        noteId,
        'test_image.jpg',
        testImageFile.path,
      );
      final images = await mediaService.getNoteImages(noteId);
      expect(images.length, greaterThan(0));

      // Test creating video directory by saving a video
      await mediaService.saveVideo(
        noteId,
        'test_video.mp4',
        testVideoFile.path,
      );
      final videos = await mediaService.getNoteVideos(noteId);
      expect(videos.length, greaterThan(0));

      // Test creating audio directory by saving audio
      await mediaService.saveAudio(
        noteId,
        'test_audio.mp3',
        testAudioFile.path,
      );
      final audios = await mediaService.getNoteAudios(noteId);
      expect(audios.length, greaterThan(0));

      // Clean up
      await mediaService.deleteNoteMedia(noteId);
      await testImageFile.delete();
      await testVideoFile.delete();
      await testAudioFile.delete();
    });

    test('Save and retrieve media files', () async {
      final noteId = 'test-note-media-files';

      // Create a temporary file to test with
      final tempDir = await getTemporaryDirectory();
      final testFile = File(path.join(tempDir.path, 'test_image.jpg'));
      await testFile.writeAsBytes([0, 1, 2, 3, 4]); // Write dummy data

      // Save the image to the note's directory
      final savedPath = await mediaService.saveImage(
        noteId,
        'test_image.jpg',
        testFile.path,
      );

      // Verify the file was saved in the correct location
      expect(savedPath.contains(noteId), isTrue);
      expect(savedPath.contains('test_image.jpg'), isTrue);

      // Check if we can retrieve the image
      final images = await mediaService.getNoteImages(noteId);
      expect(images.length, equals(1));
      expect(images.first, equals(savedPath));

      // Clean up
      await testFile.delete();
      await Directory(
        path.join(tempDir.path, 'images', noteId),
      ).delete(recursive: true);
    });

    test('Get all media for a note', () async {
      final noteId = 'test-note-all-media';

      // Create temporary files
      final tempDir = await getTemporaryDirectory();
      final testImage = File(path.join(tempDir.path, 'test_image.jpg'));
      await testImage.writeAsBytes([0, 1, 2, 3, 4]);

      final testVideo = File(path.join(tempDir.path, 'test_video.mp4'));
      await testVideo.writeAsBytes([5, 6, 7, 8, 9]);

      final testAudio = File(path.join(tempDir.path, 'test_audio.mp3'));
      await testAudio.writeAsBytes([10, 11, 12, 13, 14]);

      // Save all media types to the note
      await mediaService.saveImage(noteId, 'test_image.jpg', testImage.path);
      await mediaService.saveVideo(noteId, 'test_video.mp4', testVideo.path);
      await mediaService.saveAudio(noteId, 'test_audio.mp3', testAudio.path);

      // Get all media for the note
      final noteMedia = await mediaService.getNoteMedia(noteId);

      expect(noteMedia['images']!.length, equals(1));
      expect(noteMedia['videos']!.length, equals(1));
      expect(noteMedia['audios']!.length, equals(1));

      // Clean up
      await testImage.delete();
      await testVideo.delete();
      await testAudio.delete();
      await Directory(
        path.join(tempDir.path, 'images', noteId),
      ).delete(recursive: true);
      await Directory(
        path.join(tempDir.path, 'videos', noteId),
      ).delete(recursive: true);
      await Directory(
        path.join(tempDir.path, 'audios', noteId),
      ).delete(recursive: true);
    });

    test('Delete note media', () async {
      final noteId = 'test-note-delete-media';

      // Create temporary files
      final tempDir = await getTemporaryDirectory();
      final testImage = File(path.join(tempDir.path, 'test_image.jpg'));
      await testImage.writeAsBytes([0, 1, 2, 3, 4]);

      // Save image to note
      await mediaService.saveImage(noteId, 'test_image.jpg', testImage.path);

      // Verify file exists
      final imagesBefore = await mediaService.getNoteImages(noteId);
      expect(imagesBefore.length, equals(1));

      // Delete all media for the note
      await mediaService.deleteNoteMedia(noteId);

      // Verify files are deleted
      final imagesAfter = await mediaService.getNoteImages(noteId);
      expect(imagesAfter.length, equals(0));

      // Clean up
      await testImage.delete();
    });
  });
}
