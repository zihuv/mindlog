import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:mindlog/data/database/app_database.dart';
import 'package:get/get.dart';
import 'package:mindlog/utils/log_util.dart';

class DataExportUtil {
  /// Gets the path to the database file
  static Future<String> _getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return path.join(dbFolder.path, 'mindlog_db.sqlite');
  }

  /// Exports all notes, notebooks, and associated media files to a ZIP file at a specified location
  static Future<String> exportDataToZip() async {
    // This method creates the archive in a temporary location first
    // Use app's cache directory instead of system temp directory for better Android compatibility
    String tempPath;
    try {
      final cacheDir = await getTemporaryDirectory();
      tempPath = cacheDir.path;
    } catch (e) {
      // Fallback to app documents directory if temp directory fails
      final appDir = await getApplicationDocumentsDirectory();
      tempPath = appDir.path;
    }

    final String exportFileName =
        'mindlog_export_${DateTime.now().millisecondsSinceEpoch}.zip';
    final String tempExportPath = path.join(tempPath, exportFileName);

    // Create archive
    final Archive archive = Archive();

    // Export database by copying the SQLite file
    final String dbPath = await _getDatabasePath();
    final File dbFile = File(dbPath);
    if (await dbFile.exists()) {
      final dbBytes = await dbFile.readAsBytes();
      archive.addFile(
        ArchiveFile('database/mindlog_db.sqlite', dbBytes.length, dbBytes),
      );
    }

    // Export all media files
    await _exportMediaFiles(archive);

    // Write the archive to the temporary file
    final zipData = ZipEncoder().encode(archive);
    final zipFile = File(tempExportPath);
    await zipFile.writeAsBytes(zipData);

    return tempExportPath;
  }

  /// Exports all notes, notebooks, and associated media files to a ZIP file at a user-specified location
  static Future<bool> exportDataToZipWithSaveDialog() async {
    try {
      // First create the archive in temporary location
      logger.debug('Starting export process...');
      final String tempExportPath = await exportDataToZip();
      logger.debug('Archive created at: $tempExportPath');

      final String exportFileName =
          'mindlog_export_${DateTime.now().millisecondsSinceEpoch}.zip';
      logger.debug('Opening file picker with filename: $exportFileName');

      // Get the base path for saving (Downloads folder preferred)
      String basePath;
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          basePath = downloadsDir.path;
          logger.debug('Using Downloads directory: $basePath');
        } else {
          throw Exception('Downloads directory not available');
        }
      } catch (e) {
        logger.warning(
          'Downloads directory not available, using Documents: $e',
        );
        final docsDir = await getApplicationDocumentsDirectory();
        basePath = docsDir.path;
      }

      // Try to use file_picker's saveFile method for user to choose exact location
      String? selectedPath;
      try {
        selectedPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save backup file',
          fileName: exportFileName,
          allowedExtensions: ['zip'],
        );
        logger.debug('File picker saveFile result: $selectedPath');
      } catch (e) {
        logger.warning(
          'File picker saveFile method not available, using default path: $e',
        );
        // Don't rethrow - just use default path
        selectedPath = null;
      }

      // If user didn't select a path or file picker failed, use default location
      if (selectedPath == null) {
        logger.debug('No path selected by user, using default Downloads path');
        selectedPath = path.join(basePath, exportFileName);
      }

      // Ensure the selected path has the correct extension
      String finalPath = selectedPath;
      if (!finalPath.endsWith('.zip')) {
        finalPath = '$selectedPath.zip';
      }

      logger.debug('Final export path: $finalPath');

      // Create parent directories if they don't exist
      final parentDir = Directory(path.dirname(finalPath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
        logger.debug('Created directory: ${path.dirname(finalPath)}');
      }

      // Move the temporary file to the selected location
      final tempFile = File(tempExportPath);
      logger.debug('Copying file from $tempExportPath to $finalPath');
      await tempFile.copy(finalPath);
      logger.debug('File copied successfully to $finalPath');

      // Delete the temporary file
      try {
        await tempFile.delete();
      } catch (e) {
        logger.warning('Failed to delete temporary file: $e');
      }

      // Show success message
      if (Get.isOverlaysOpen) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              'Backup exported successfully!\nLocation: $finalPath',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      logger.info('Export completed successfully at: $finalPath');
      return true;
    } catch (e) {
      logger.error('Export failed: $e', stackTrace: StackTrace.current);
      // Show error message
      if (Get.isOverlaysOpen) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Don't rethrow - just return false to indicate failure
      return false;
    }
  }

  /// Exports all media files to the archive
  static Future<void> _exportMediaFiles(Archive archive) async {
    final appDir = await getApplicationDocumentsDirectory();

    // Export images directory
    final imagesDir = Directory(path.join(appDir.path, 'images'));
    if (await imagesDir.exists()) {
      await for (final entity in imagesDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: appDir.path);
          final fileBytes = await entity.readAsBytes();
          archive.addFile(
            ArchiveFile('media/$relativePath', fileBytes.length, fileBytes),
          );
        } else if (entity is Link) {
          // Handle symbolic links by reading the actual file content
          try {
            final target = await entity.resolveSymbolicLinks();
            final targetFile = File(target);
            if (await targetFile.exists()) {
              final relativePath = path.relative(
                entity.path,
                from: appDir.path,
              );
              final fileBytes = await targetFile.readAsBytes();
              archive.addFile(
                ArchiveFile('media/$relativePath', fileBytes.length, fileBytes),
              );
            }
          } catch (e) {
            // If we can't resolve the link, skip it
            logger.warning('Could not resolve symbolic link: ${entity.path}');
          }
        }
      }
    }

    // Export videos directory
    final videosDir = Directory(path.join(appDir.path, 'videos'));
    if (await videosDir.exists()) {
      await for (final entity in videosDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: appDir.path);
          final fileBytes = await entity.readAsBytes();
          archive.addFile(
            ArchiveFile('media/$relativePath', fileBytes.length, fileBytes),
          );
        } else if (entity is Link) {
          // Handle symbolic links by reading the actual file content
          try {
            final target = await entity.resolveSymbolicLinks();
            final targetFile = File(target);
            if (await targetFile.exists()) {
              final relativePath = path.relative(
                entity.path,
                from: appDir.path,
              );
              final fileBytes = await targetFile.readAsBytes();
              archive.addFile(
                ArchiveFile('media/$relativePath', fileBytes.length, fileBytes),
              );
            }
          } catch (e) {
            // If we can't resolve the link, skip it
            logger.warning('Could not resolve symbolic link: ${entity.path}');
          }
        }
      }
    }

    // Export audios directory
    final audiosDir = Directory(path.join(appDir.path, 'audios'));
    if (await audiosDir.exists()) {
      await for (final entity in audiosDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: appDir.path);
          final fileBytes = await entity.readAsBytes();
          archive.addFile(
            ArchiveFile('media/$relativePath', fileBytes.length, fileBytes),
          );
        } else if (entity is Link) {
          // Handle symbolic links by reading the actual file content
          try {
            final target = await entity.resolveSymbolicLinks();
            final targetFile = File(target);
            if (await targetFile.exists()) {
              final relativePath = path.relative(
                entity.path,
                from: appDir.path,
              );
              final fileBytes = await targetFile.readAsBytes();
              archive.addFile(
                ArchiveFile('media/$relativePath', fileBytes.length, fileBytes),
              );
            }
          } catch (e) {
            // If we can't resolve the link, skip it
            logger.warning('Could not resolve symbolic link: ${entity.path}');
          }
        }
      }
    }
  }

  /// Imports data from a ZIP file, restoring notes, notebooks, and media files
  static Future<void> importDataFromZip(
    String zipFilePath, {
    Function(double)? onProgress,
  }) async {
    final zipFile = File(zipFilePath);
    if (!await zipFile.exists()) {
      throw Exception('ZIP file does not exist: $zipFilePath');
    }

    // Read and decode the ZIP file
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Report progress: 10% after reading archive
    if (onProgress != null) onProgress(0.1);

    // Import database file
    await _importDatabaseFromArchive(archive);

    // Report progress: 30% after importing database
    if (onProgress != null) onProgress(0.3);

    // Import media files
    await _importMediaFilesFromArchive(
      archive,
      onProgress: onProgress != null
          ? (progress) {
              // Scale progress from 30% to 90%
              onProgress(0.3 + progress * 0.6);
            }
          : null,
    );

    // Report progress: 90% after importing media files
    if (onProgress != null) onProgress(0.9);

    // Show success message
    if (Get.isOverlaysOpen) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text(
            'Backup imported successfully! Restarting database connection...',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Report progress: 100% when done
    if (onProgress != null) onProgress(1.0);

    // Give a small delay to ensure all files are written
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Imports the database file from the archive
  static Future<void> _importDatabaseFromArchive(Archive archive) async {
    ArchiveFile? dbFile;
    for (final file in archive) {
      if (file.name == 'database/mindlog_db.sqlite') {
        dbFile = file;
        break;
      }
    }

    if (dbFile != null) {
      // Close current database connection
      await Get.find<DatabaseProvider>().close();

      // Write the database file to the appropriate location
      final appDir = await getApplicationDocumentsDirectory();
      final newDbPath = path.join(appDir.path, 'mindlog_db.sqlite');
      final newDbFile = File(newDbPath);

      // Delete existing database file if it exists
      if (await newDbFile.exists()) {
        await newDbFile.delete();
      }

      // Write the new database file
      await newDbFile.writeAsBytes(dbFile.content as List<int>);

      // Reinitialize the database connection
      await _reinitializeDatabaseConnection();
    } else {
      // Handle older backup formats where database was stored directly in the archive root
      for (final file in archive) {
        if (file.name == 'mindlog_db.sqlite') {
          dbFile = file;
          break;
        }
      }

      if (dbFile != null) {
        // Close current database connection
        await Get.find<DatabaseProvider>().close();

        // Write the database file to the appropriate location
        final appDir = await getApplicationDocumentsDirectory();
        final newDbPath = path.join(appDir.path, 'mindlog_db.sqlite');
        final newDbFile = File(newDbPath);

        // Delete existing database file if it exists
        if (await newDbFile.exists()) {
          await newDbFile.delete();
        }

        // Write the new database file
        await newDbFile.writeAsBytes(dbFile.content as List<int>);

        // Reinitialize the database connection
        await _reinitializeDatabaseConnection();
      }
    }
  }

  /// Reinitializes the database connection after importing a new database file
  static Future<void> _reinitializeDatabaseConnection() async {
    try {
      // Close the existing database connection
      await Get.find<DatabaseProvider>().close();

      // Wait a moment to ensure connection is fully closed
      await Future.delayed(const Duration(milliseconds: 100));

      // Reset the database provider to force reinitialization
      await Get.find<DatabaseProvider>().reset();

      // The database will be reinitialized when accessed again
      logger.debug('Database connection reinitialized successfully');
    } catch (e) {
      logger.error('Error reinitializing database connection: $e');
    }
  }

  /// Imports media files from the archive
  static Future<void> _importMediaFilesFromArchive(
    Archive archive, {
    Function(double)? onProgress,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();

    // Collect all media files first
    final List<ArchiveFile> mediaFiles = [];
    for (final file in archive) {
      if (file.name.startsWith('media/') ||
          file.name.startsWith('images/') ||
          file.name.startsWith('videos/') ||
          file.name.startsWith('audios/')) {
        mediaFiles.add(file);
      }
    }

    // Check if we're on a Unix-like system where we can use symbolic links
    bool canUseSymlinks = Platform.isMacOS || Platform.isLinux;

    // Process each media file
    for (int i = 0; i < mediaFiles.length; i++) {
      final file = mediaFiles[i];

      // Report progress
      if (onProgress != null) {
        onProgress(i / mediaFiles.length);
      }

      String relativePath;
      if (file.name.startsWith('media/')) {
        // New format: remove 'media/' prefix
        relativePath = file.name.substring('media/'.length);
      } else {
        // Old format: use path as-is
        relativePath = file.name;
      }

      final filePath = path.join(appDir.path, relativePath);

      // Create parent directories if they don't exist
      final fileDir = Directory(path.dirname(filePath));
      await fileDir.create(recursive: true);

      if (canUseSymlinks) {
        // On Unix-like systems, first write to a temporary location
        final tempPath = '$filePath.import.tmp';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(file.content as List<int>);

        // Then create a symbolic link
        await _createSymbolicLink(tempPath, filePath);
      } else {
        // On Windows or other systems, just write the file normally
        final mediaFile = File(filePath);
        await mediaFile.writeAsBytes(file.content as List<int>);
      }
    }

    // Report final progress for media files
    if (onProgress != null) {
      onProgress(1.0);
    }
  }

  /// Creates a symbolic link to a file (Unix-like systems only)
  static Future<void> _createSymbolicLink(
    String originalPath,
    String linkPath,
  ) async {
    try {
      // Delete existing file or link at the destination
      final linkFile = File(linkPath);
      if (await linkFile.exists()) {
        await linkFile.delete();
      }

      // Create symbolic link
      await Process.run('ln', ['-s', originalPath, linkPath]);
    } catch (e) {
      // If linking fails, fall back to copying the file
      final originalFile = File(originalPath);
      // final linkFile = File(linkPath); // Not used, commented out
      await originalFile.copy(linkPath);
    }
  }
}
