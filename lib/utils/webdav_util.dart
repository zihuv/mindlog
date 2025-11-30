import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../data/services/combined_note_service.dart';
import '../features/notes/domain/entities/note.dart';
import '../utils/notebook_sync_manager.dart';
import 'log_util.dart';

class WebDAVConfig {
  final String url;
  final String username;
  final String password;
  final String folderName;

  WebDAVConfig({
    required this.url,
    required this.username,
    required this.password,
    this.folderName = 'mindlog',
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'username': username,
    'password': password,
    'folderName': folderName,
  };

  factory WebDAVConfig.fromJson(Map<String, dynamic> json) => WebDAVConfig(
    url: json['url'] ?? '',
    username: json['username'] ?? '',
    password: json['password'] ?? '',
    folderName: json['folderName'] ?? 'mindlog',
  );
}

class SyncStatus {
  final bool needsUpload;
  final bool needsDownload;
  final String localTimestamp;
  final String? remoteTimestamp;

  SyncStatus({
    required this.needsUpload,
    required this.needsDownload,
    required this.localTimestamp,
    this.remoteTimestamp,
  });
}

class WebDAVUtil {
  static const String _syncFileName = 'sync.json';
  static const String _notesDir = 'Note';
  static const String _assetsDir = 'Asset';
  static const String _imageDir = 'Image';
  static const String _videoDir = 'Video';
  static const String _audioDir = 'Audio';

  webdav.Client? _client;
  late WebDAVConfig _config;
  late String _rootPath;
  late CombinedNoteService _noteService;
  late NotebookSyncManager _notebookSyncManager;

  WebDAVUtil({CombinedNoteService? noteService}) {
    _noteService = noteService ?? CombinedNoteService();
    _notebookSyncManager = NotebookSyncManager();
  }

  Future<void> init(WebDAVConfig config) async {
    _config = config;
    _rootPath = '/${_config.folderName}/';

    _client = webdav.newClient(
      _config.url,
      user: _config.username,
      password: _config.password,
      debug: false,
    );

    _client?.setHeaders({
      'accept-charset': 'utf-8',
      'Content-Type': 'application/json',
    });

    // Initialize notebook sync manager with the same credentials
    await _notebookSyncManager.initClient(
      _config.url,
      _config.username,
      _config.password,
      _config.folderName,
    );

    logger.info('WebDAV client initialized with URL: ${_config.url} and folder: ${_config.folderName}');
  }

  Future<bool> testConnection() async {
    if (_client == null) {
      logger.error('WebDAV client not initialized');
      return false;
    }
    
    try {
      logger.info('Testing WebDAV connection');
      await _client!.ping().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          logger.error('WebDAV ping operation timed out');
          throw TimeoutException(
            'Ping operation timed out',
            const Duration(seconds: 5),
          );
        },
      );
      logger.info('WebDAV connection test successful');
      return true;
    } catch (e, s) {
      logger.error('WebDAV connectivity check failed', error: e, stackTrace: s);
      return false;
    }
  }

  Future<void> sync() async {
    if (_client == null) {
      logger.error('WebDAV not initialized. Call init() first.');
      throw Exception('WebDAV not initialized. Call init() first.');
    }

    try {
      logger.info('Starting WebDAV sync process');
      // Ensure the directory structure exists
      await _ensureDirectoryStructure();

      // Download sync.json from WebDAV
      Map<String, dynamic> remoteSyncData = await _downloadSyncFile();

      // Sync notes
      await _syncNotes(remoteSyncData);

      // Sync notebooks
      await _syncNotebooks();

      logger.info('WebDAV sync process completed successfully');
    } catch (e, s) {
      logger.error('Error during sync', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> _syncNotes(Map<String, dynamic> remoteSyncData) async {
    // Get all local notes
    await _noteService.init();
    List<Note> localNotes = await _noteService.getAllNotes();
    logger.info('Found ${localNotes.length} local notes');

    // Calculate sync status for each note
    Map<String, SyncStatus> syncStatusMap = await _calculateSyncStatus(
      localNotes,
      remoteSyncData,
    );

    // Process sync operations
    await _processSyncOperations(syncStatusMap, localNotes);

    // Update sync.json after sync
    await _updateSyncFile(syncStatusMap);
  }

  Future<void> _syncNotebooks() async {
    logger.info('Starting notebook sync process');
    try {
      await _notebookSyncManager.sync();
      logger.info('Notebook sync process completed successfully');
    } catch (e, s) {
      logger.error('Error during notebook sync', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> _ensureDirectoryStructure() async {
    final directories = [
      _rootPath,
      '$_rootPath$_notesDir/',
      '$_rootPath$_assetsDir/',
      '$_rootPath$_assetsDir/$_imageDir/',
      '$_rootPath$_assetsDir/$_videoDir/',
      '$_rootPath$_assetsDir/$_audioDir/',
      '$_rootPath/Notebook/', // For notebook files
    ];

    logger.debug('Ensuring WebDAV directory structure exists');
    for (final dir in directories) {
      try {
        await _client!.mkdirAll(dir);
        logger.debug('Created/verified directory: $dir');
      } catch (e) {
        logger.warning('Failed to create directory $dir (may already exist)');
      }
    }
  }

  Future<Map<String, dynamic>> _downloadSyncFile() async {
    try {
      logger.debug('Downloading sync file from WebDAV');
      final response = await _client!.read(_rootPath + _syncFileName);
      if (response.isNotEmpty) {
        String remoteSyncContent = utf8.decode(response);
        logger.debug('Sync file downloaded successfully');
        return jsonDecode(remoteSyncContent);
      }
      logger.debug('Sync file is empty');
      return {};
    } catch (e) {
      logger.warning('Sync file does not exist on server, starting fresh');
      return {};
    }
  }

  Future<Map<String, SyncStatus>> _calculateSyncStatus(
    List<Note> localNotes,
    Map<String, dynamic> remoteSyncData,
  ) async {
    Map<String, SyncStatus> syncStatusMap = {};

    // Check all local notes
    for (final note in localNotes) {
      String noteId = note.id;
      String localTimestamp = _formatTimestamp(
        note.updateTime ?? note.createTime,
      );
      String? remoteTimestamp = remoteSyncData[noteId] as String?;

      // Determine if the note needs to be uploaded, downloaded, or both
      bool needsUpload = false;
      bool needsDownload = false;

      if (remoteTimestamp == null) {
        // Note doesn't exist on server, needs upload
        needsUpload = true;
      } else if (remoteTimestamp == 'delete') {
        // Note was deleted on server, but exists locally
        // Check if note is marked as deleted locally
        if (note.isDeleted) {
          // Both sides are deleted, no action needed
          needsUpload = false;
          needsDownload = false;
        } else {
          // Note exists locally but was deleted on server
          // Mark for deletion locally
          needsDownload = true;
        }
      } else {
        // Compare timestamps to determine which version is newer
        DateTime localTime =
            DateTime.tryParse(localTimestamp) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        DateTime remoteTime =
            DateTime.tryParse(remoteTimestamp) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        if (localTime.isAfter(remoteTime)) {
          needsUpload = true;
        } else if (remoteTime.isAfter(localTime)) {
          needsDownload = true;
        }
      }

      syncStatusMap[noteId] = SyncStatus(
        needsUpload: needsUpload,
        needsDownload: needsDownload,
        localTimestamp: localTimestamp,
        remoteTimestamp: remoteTimestamp,
      );
    }

    // Check for notes that exist remotely but not locally (for deletion)
    for (final entry in remoteSyncData.entries) {
      String noteId = entry.key;
      String? remoteStatus = entry.value as String?;

      if (remoteStatus == 'delete') {
        // If the note was deleted remotely, mark it for local deletion
        if (!syncStatusMap.containsKey(noteId)) {
          syncStatusMap[noteId] = SyncStatus(
            needsUpload: false,
            needsDownload: true, // Need to download the deletion
            localTimestamp: '0',
          );
        }
      } else if (remoteStatus != null && !syncStatusMap.containsKey(noteId)) {
        // Note exists remotely but not locally, needs download
        syncStatusMap[noteId] = SyncStatus(
          needsUpload: false,
          needsDownload: true,
          localTimestamp: '0',
          remoteTimestamp: remoteStatus,
        );
      }
    }

    return syncStatusMap;
  }

  Future<void> _processSyncOperations(
    Map<String, SyncStatus> syncStatusMap,
    List<Note> localNotes,
  ) async {
    // Process downloads first (notes that need to be downloaded from server)
    for (final entry in syncStatusMap.entries) {
      String noteId = entry.key;
      SyncStatus status = entry.value;

      if (status.needsDownload) {
        await _downloadNote(noteId);
      }
    }

    // Process uploads (notes that need to be uploaded to server)
    for (final entry in syncStatusMap.entries) {
      String noteId = entry.key;
      SyncStatus status = entry.value;

      if (status.needsUpload) {
        // Find the local note
        Note? localNote;
        try {
          localNote = localNotes.firstWhere((note) => note.id == noteId);
        } catch (e) {
          // Note not found in localNotes list
          localNote = null;
        }

        if (localNote != null) {
          // Check if note is marked as deleted locally
          if (localNote.isDeleted) {
            // Upload deletion marker to server
            await _markNoteAsDeletedOnServer(noteId);
          } else {
            await _uploadNote(localNote);
          }
        } else if (status.remoteTimestamp != 'delete') {
          // If local note doesn't exist but remote status isn't 'delete',
          // then we should remove it from sync status (it might have been deleted locally)
        }
      }
    }
  }

  Future<void> _uploadNote(Note note) async {
    try {
      logger.debug('Uploading note: ${note.id}');
      
      // Check if note is marked as deleted
      if (note.isDeleted) {
        await _markNoteAsDeletedOnServer(note.id);
        return;
      }
      
      // Upload the note JSON file
      String noteJson = jsonEncode(note.toJson());
      String noteYear = _getYearFromTimestamp(
        note.updateTime ?? note.createTime,
      );
      String notePath = '$_rootPath$_notesDir/$noteYear/${note.id}.json';

      // Create the year directory if it doesn't exist
      await _client!.mkdirAll('$_rootPath$_notesDir/$noteYear/');

      _client!.setHeaders({
        'accept-charset': 'utf-8',
        'Content-Type': 'application/json',
      });

      await _client!.write(
        notePath,
        Uint8List.fromList(utf8.encode(noteJson))
      );

      // Upload associated images if they exist
      for (String imageName in note.images) {
        await _uploadImage(note.id, imageName, noteCreateTime: note.createTime);
      }

      // Upload associated videos if they exist
      for (String videoName in note.videos) {
        await _uploadVideo(note.id, videoName, noteCreateTime: note.createTime);
      }

      // Upload associated audios if they exist
      for (String audioName in note.audios) {
        await _uploadAudio(note.id, audioName, noteCreateTime: note.createTime);
      }

      logger.info('Successfully uploaded note: ${note.id}');
    } catch (e, s) {
      logger.error('Error uploading note ${note.id}', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> _downloadNote(String noteId) async {
    try {
      logger.debug('Downloading note: $noteId');
      // Try different years to find the note file since we don't know the creation year
      List<int> possibleYears = await _getPossibleYears();
      Uint8List? noteBytes;

      for (int year in possibleYears) {
        String path = '$_rootPath$_notesDir/$year/$noteId.json';
        try {
          List<int> bytes = await _client!.read(path);
          noteBytes = Uint8List.fromList(bytes);
          logger.debug('Found note $noteId in year $year');
          break;
        } catch (e) {
          // Continue to next year
          continue;
        }
      }

      if (noteBytes == null) {
        // Note doesn't exist on server, might have been deleted
        Note? existingNote = await _noteService.getNoteById(noteId);
        if (existingNote != null) {
          await _noteService.deleteNote(noteId);
          logger.info('Note deleted locally as it was removed from server: $noteId');
        }
        // Also mark in sync status that this note is deleted on server
        return;
      }

      String noteContent = utf8.decode(noteBytes);
      Map<String, dynamic> noteData = jsonDecode(noteContent);
      Note note = Note.fromJson(noteData);

      // Check if the note from server is marked as deleted
      if (note.isDeleted) {
        // Delete locally as well
        Note? existingNote = await _noteService.getNoteById(noteId);
        if (existingNote != null) {
          await _noteService.deleteNote(noteId);
          logger.info('Note deleted locally as it was marked as deleted on server: $noteId');
        }
        return;
      }

      // Check if note exists locally
      Note? existingNote = await _noteService.getNoteById(noteId);

      if (existingNote != null) {
        // Update existing note preserving cloud data (ID, createTime, updateTime)
        await _noteService.updateNote(
          id: note.id,
          content: note.content,
          notebookId: note.notebookId,
          updateTime: note.updateTime, // Preserve the cloud updateTime
        );

        // Update the note's media to match the cloud data
        await _noteService.updateNoteMedia(
          id: note.id,
          imageNames: note.images,
          videoNames: note.videos,
          audioNames: note.audios,
          noteContent: note.content,
          notebookId: note.notebookId,
        );

        logger.debug('Updated existing note: $noteId');
      } else {
        // Create new note preserving cloud data (ID, createTime, updateTime)
        // Use the new method that preserves all cloud data
        await _noteService.saveNoteWithCloudData(
          id: note.id,
          content: note.content,
          createTime: note.createTime,
          updateTime: note.updateTime,
          images: note.images,
          videos: note.videos,
          audios: note.audios,
          notebookId: note.notebookId,
        );

        logger.debug('Created new note: $noteId with full cloud data preserved');
      }

      // Download associated images if they exist
      for (String imageName in note.images) {
        await _downloadImage(note.id, imageName, note.createTime);
      }

      // Download associated videos if they exist
      for (String videoName in note.videos) {
        await _downloadVideo(note.id, videoName, note.createTime);
      }

      // Download associated audios if they exist
      for (String audioName in note.audios) {
        await _downloadAudio(note.id, audioName, note.createTime);
      }

      logger.info('Successfully downloaded note: $noteId');
    } catch (e, s) {
      logger.error('Error downloading note $noteId', error: e, stackTrace: s);
    }
  }

  Future<List<int>> _getPossibleYears() async {
    try {
      // List all directories under the Note directory to get possible years
      var items = await _client!.readDir('$_rootPath$_notesDir/');
      List<int> years = [];

      for (var item in items) {
        String? itemName = item.name;
        // Check if it's a directory
        if (item.isDir == true && itemName != null && itemName.isNotEmpty) {
          // Try to parse the directory name as a year
          try {
            int year = int.parse(itemName);
            if (year > 2000 && year < 2100) {
              // Reasonable year range
              years.add(year);
            }
          } catch (e) {
            // Not a valid year, skip
            continue;
          }
        }
      }

      return years;
    } catch (e) {
      logger.error('Error getting possible years', error: e);
      // Default to a few recent years
      int currentYear = DateTime.now().year;
      return [currentYear, currentYear - 1, currentYear - 2];
    }
  }

  Future<void> _uploadImage(String noteId, String imageName, {DateTime? noteCreateTime}) async {
    try {
      logger.debug('Uploading image $imageName for note: $noteId');
      // Get the local image path
      final appDir = await getApplicationDocumentsDirectory();
      String imagePath = path.join(appDir.path, 'images', noteId, imageName);

      File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        // Calculate the destination path on WebDAV using the note's creation time for consistency
        String imageYearPath = _getYearFromTimestamp(noteCreateTime ?? DateTime.now());
        String destinationPath =
            '$_rootPath$_assetsDir/$_imageDir/$imageYearPath/$noteId/$imageName';

        // Create the directory if it doesn't exist
        await _client!.mkdirAll('${path.dirname(destinationPath)}/');

        // Upload the image file
        List<int> imageBytes = await imageFile.readAsBytes();

        _client!.setHeaders({
          'accept-charset': 'utf-8',
          'Content-Type': 'application/octet-stream',
        });

        await _client!.write(destinationPath, Uint8List.fromList(imageBytes));

        logger.debug('Successfully uploaded image: $destinationPath');
      } else {
        logger.warning('Local image does not exist: $imagePath');
      }
    } catch (e, s) {
      logger.error('Error uploading image for note $noteId', error: e, stackTrace: s);
    }
  }

  Future<void> _uploadVideo(String noteId, String videoName, {DateTime? noteCreateTime}) async {
    try {
      logger.debug('Uploading video $videoName for note: $noteId');
      // Get the local video path
      final appDir = await getApplicationDocumentsDirectory();
      String videoPath = path.join(appDir.path, 'videos', noteId, videoName);

      File videoFile = File(videoPath);
      if (await videoFile.exists()) {
        // Calculate the destination path on WebDAV using the note's creation time for consistency
        String videoYearPath = _getYearFromTimestamp(noteCreateTime ?? DateTime.now());
        String destinationPath =
            '$_rootPath$_assetsDir/$_videoDir/$videoYearPath/$noteId/$videoName';

        // Create the directory if it doesn't exist
        await _client!.mkdirAll('${path.dirname(destinationPath)}/');

        // Upload the video file
        List<int> videoBytes = await videoFile.readAsBytes();

        _client!.setHeaders({
          'accept-charset': 'utf-8',
          'Content-Type': 'application/octet-stream',
        });

        await _client!.write(destinationPath, Uint8List.fromList(videoBytes));

        logger.debug('Successfully uploaded video: $destinationPath');
      } else {
        logger.warning('Local video does not exist: $videoPath');
      }
    } catch (e, s) {
      logger.error('Error uploading video for note $noteId', error: e, stackTrace: s);
    }
  }

  Future<void> _uploadAudio(String noteId, String audioName, {DateTime? noteCreateTime}) async {
    try {
      logger.debug('Uploading audio $audioName for note: $noteId');
      // Get the local audio path
      final appDir = await getApplicationDocumentsDirectory();
      String audioPath = path.join(appDir.path, 'audios', noteId, audioName);

      File audioFile = File(audioPath);
      if (await audioFile.exists()) {
        // Calculate the destination path on WebDAV using the note's creation time for consistency
        String audioYearPath = _getYearFromTimestamp(noteCreateTime ?? DateTime.now());
        String destinationPath =
            '$_rootPath$_assetsDir/$_audioDir/$audioYearPath/$noteId/$audioName';

        // Create the directory if it doesn't exist
        await _client!.mkdirAll('${path.dirname(destinationPath)}/');

        // Upload the audio file
        List<int> audioBytes = await audioFile.readAsBytes();

        _client!.setHeaders({
          'accept-charset': 'utf-8',
          'Content-Type': 'application/octet-stream',
        });

        await _client!.write(destinationPath, Uint8List.fromList(audioBytes));

        logger.debug('Successfully uploaded audio: $destinationPath');
      } else {
        logger.warning('Local audio does not exist: $audioPath');
      }
    } catch (e, s) {
      logger.error('Error uploading audio for note $noteId', error: e, stackTrace: s);
    }
  }

  Future<void> _downloadImage(String noteId, String imageName, DateTime? noteCreateTime) async {
    try {
      logger.debug('Downloading image $imageName for note: $noteId');
      // Calculate the source path on WebDAV using the note's creation time for consistency
      String imageYearPath = _getYearFromTimestamp(noteCreateTime ?? DateTime.now());
      String sourcePath =
          '$_rootPath$_assetsDir/$_imageDir/$imageYearPath/$noteId/$imageName';

      // Download the image file
      List<int> imageBytesList = await _client!.read(sourcePath);
      Uint8List imageBytes = Uint8List.fromList(imageBytesList);

      // Get the local image path
      final appDir = await getApplicationDocumentsDirectory();
      String localImagePath = path.join(appDir.path, 'images', noteId);

      // Create directory if it doesn't exist
      Directory localImageDir = Directory(localImagePath);
      if (!await localImageDir.exists()) {
        await localImageDir.create(recursive: true);
      }

      String localImageFilePath = path.join(localImagePath, imageName);
      File localImageFile = File(localImageFilePath);

      // Write image to local file
      await localImageFile.writeAsBytes(imageBytes);

      logger.debug('Successfully downloaded image: $sourcePath to $localImageFilePath');
    } catch (e, s) {
      logger.error('Error downloading image for note $noteId', error: e, stackTrace: s);
    }
  }

  Future<void> _downloadVideo(String noteId, String videoName, DateTime? noteCreateTime) async {
    try {
      logger.debug('Downloading video $videoName for note: $noteId');
      // Calculate the source path on WebDAV using the note's creation time for consistency
      String videoYearPath = _getYearFromTimestamp(noteCreateTime ?? DateTime.now());
      String sourcePath =
          '$_rootPath$_assetsDir/$_videoDir/$videoYearPath/$noteId/$videoName';

      // Download the video file
      List<int> videoBytesList = await _client!.read(sourcePath);
      Uint8List videoBytes = Uint8List.fromList(videoBytesList);

      // Get the local video path
      final appDir = await getApplicationDocumentsDirectory();
      String localVideoPath = path.join(appDir.path, 'videos', noteId);

      // Create directory if it doesn't exist
      Directory localVideoDir = Directory(localVideoPath);
      if (!await localVideoDir.exists()) {
        await localVideoDir.create(recursive: true);
      }

      String localVideoFilePath = path.join(localVideoPath, videoName);
      File localVideoFile = File(localVideoFilePath);

      // Write video to local file
      await localVideoFile.writeAsBytes(videoBytes);

      logger.debug('Successfully downloaded video: $sourcePath to $localVideoFilePath');
    } catch (e, s) {
      logger.error('Error downloading video for note $noteId', error: e, stackTrace: s);
    }
  }

  Future<void> _downloadAudio(String noteId, String audioName, DateTime? noteCreateTime) async {
    try {
      logger.debug('Downloading audio $audioName for note: $noteId');
      // Calculate the source path on WebDAV using the note's creation time for consistency
      String audioYearPath = _getYearFromTimestamp(noteCreateTime ?? DateTime.now());
      String sourcePath =
          '$_rootPath$_assetsDir/$_audioDir/$audioYearPath/$noteId/$audioName';

      // Download the audio file
      List<int> audioBytesList = await _client!.read(sourcePath);
      Uint8List audioBytes = Uint8List.fromList(audioBytesList);

      // Get the local audio path
      final appDir = await getApplicationDocumentsDirectory();
      String localAudioPath = path.join(appDir.path, 'audios', noteId);

      // Create directory if it doesn't exist
      Directory localAudioDir = Directory(localAudioPath);
      if (!await localAudioDir.exists()) {
        await localAudioDir.create(recursive: true);
      }

      String localAudioFilePath = path.join(localAudioPath, audioName);
      File localAudioFile = File(localAudioFilePath);

      // Write audio to local file
      await localAudioFile.writeAsBytes(audioBytes);

      logger.debug('Successfully downloaded audio: $sourcePath to $localAudioFilePath');
    } catch (e, s) {
      logger.error('Error downloading audio for note $noteId', error: e, stackTrace: s);
    }
  }

  Future<void> _updateSyncFile(Map<String, SyncStatus> syncStatusMap) async {
    try {
      logger.debug('Updating sync file with ${syncStatusMap.length} entries');
      Map<String, String> syncData = {};

      for (final entry in syncStatusMap.entries) {
        String noteId = entry.key;
        SyncStatus status = entry.value;

        // Check if the note is deleted locally
        Note? localNote = await _noteService.getNoteById(noteId);
        
        if (localNote != null && localNote.isDeleted) {
          // Mark deleted notes specially in sync file
          syncData[noteId] = 'delete';
        } else if (status.needsUpload || status.needsDownload) {
          // Use the newer timestamp (local or remote) if there was a sync operation
          syncData[noteId] = status.localTimestamp;
        } else {
          // Use the original remote timestamp if no sync occurred
          syncData[noteId] = status.remoteTimestamp ?? status.localTimestamp;
        }
      }

      String syncJson = jsonEncode(syncData);
      
      _client!.setHeaders({
        'accept-charset': 'utf-8',
        'Content-Type': 'application/json',
      });
      
      await _client!.write(
        _rootPath + _syncFileName,
        Uint8List.fromList(utf8.encode(syncJson)),
      );

      logger.info('Sync file updated successfully with ${syncData.length} entries');
    } catch (e, s) {
      logger.error('Error updating sync file', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> _markNoteAsDeletedOnServer(String noteId) async {
    try {
      logger.debug('Marking note as deleted on server: $noteId');
      
      // Create a simple JSON with just the delete marker
      Map<String, dynamic> deleteMarker = {
        'id': noteId,
        'isDeleted': true,
      };
      
      String deleteJson = jsonEncode(deleteMarker);
      String noteYear = DateTime.now().year.toString();
      String notePath = '$_rootPath$_notesDir/$noteYear/$noteId.json';

      // Create the year directory if it doesn't exist
      await _client!.mkdirAll('$_rootPath$_notesDir/$noteYear/');

      _client!.setHeaders({
        'accept-charset': 'utf-8',
        'Content-Type': 'application/json',
      });

      await _client!.write(
        notePath,
        Uint8List.fromList(utf8.encode(deleteJson))
      );

      logger.info('Successfully marked note as deleted on server: $noteId');
    } catch (e, s) {
      logger.error('Error marking note as deleted on server $noteId', error: e, stackTrace: s);
      rethrow;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  String _getYearFromTimestamp(DateTime dateTime) {
    return dateTime.year.toString();
  }

  void dispose() {
    _client = null;
    _notebookSyncManager.dispose();
  }
}









