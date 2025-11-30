import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../data/services/combined_note_service.dart';
import '../features/notes/domain/entities/note.dart';

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

  webdav.Client? _client;
  late WebDAVConfig _config;
  late String _rootPath;
  late CombinedNoteService _noteService;

  WebDAVUtil({CombinedNoteService? noteService}) {
    _noteService = noteService ?? CombinedNoteService();
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
  }

  Future<bool> testConnection() async {
    if (_client == null) {
      return false;
    }
    
    try {
      await _client!.ping().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException(
            'Ping operation timed out',
            const Duration(seconds: 5),
          );
        },
      );
      return true;
    } catch (e) {
      print('WebDAV connectivity check failed: $e');
      return false;
    }
  }

  Future<void> sync() async {
    if (_client == null) {
      throw Exception('WebDAV not initialized. Call init() first.');
    }

    try {
      // Ensure the directory structure exists
      await _ensureDirectoryStructure();

      // Download sync.json from WebDAV
      Map<String, dynamic> remoteSyncData = await _downloadSyncFile();

      // Get all local notes
      await _noteService.init();
      List<Note> localNotes = await _noteService.getAllNotes();

      // Calculate sync status for each note
      Map<String, SyncStatus> syncStatusMap = await _calculateSyncStatus(
        localNotes,
        remoteSyncData,
      );

      // Process sync operations
      await _processSyncOperations(syncStatusMap, localNotes);

      // Update sync.json after sync
      await _updateSyncFile(syncStatusMap);
    } catch (e) {
      // print('Error during sync: $e');
      rethrow;
    }
  }

  Future<void> _ensureDirectoryStructure() async {
    final directories = [
      _rootPath,
      '$_rootPath$_notesDir/',
      '$_rootPath$_assetsDir/',
      '$_rootPath$_assetsDir/$_imageDir/',
    ];

    for (final dir in directories) {
      try {
        await _client!.mkdirAll(dir);
      } catch (e) {
        // Directory might already exist, continue
        // print('Directory creation failed for $dir: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _downloadSyncFile() async {
    try {
      final response = await _client!.read(_rootPath + _syncFileName);
      if (response.isNotEmpty) {
        String remoteSyncContent = utf8.decode(response);
        return jsonDecode(remoteSyncContent);
      }
      return {};
    } catch (e) {
      // If sync file doesn't exist, return empty map
      // print('Sync file does not exist on server, starting fresh: $e');
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
        needsUpload = true;
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
            needsDownload: false,
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
          await _uploadNote(localNote);
        } else if (status.remoteTimestamp != 'delete') {
          // If local note doesn't exist but remote status isn't 'delete',
          // then we should remove it from sync status (it might have been deleted locally)
        }
      }
    }
  }

  Future<void> _uploadNote(Note note) async {
    try {
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
        await _uploadImage(note.id, imageName);
      }

      // print('Successfully uploaded note: ${note.id}');
    } catch (e) {
      // print('Error uploading note ${note.id}: $e');
      rethrow;
    }
  }

  Future<void> _downloadNote(String noteId) async {
    try {
      // Try different years to find the note file since we don't know the creation year
      List<int> possibleYears = await _getPossibleYears();
      Uint8List? noteBytes;

      for (int year in possibleYears) {
        String path = '$_rootPath$_notesDir/$year/$noteId.json';
        try {
          List<int> bytes = await _client!.read(path);
          noteBytes = Uint8List.fromList(bytes);
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
          // print('Note deleted locally: $noteId');
        }
        return;
      }

      String noteContent = utf8.decode(noteBytes);
      Map<String, dynamic> noteData = jsonDecode(noteContent);
      Note note = Note.fromJson(noteData);

      // Check if note exists locally
      Note? existingNote = await _noteService.getNoteById(noteId);

      if (existingNote != null) {
        // Update existing note
        await _noteService.updateNote(
          id: note.id,
          content: note.content,
          notebookId: note.notebookId,
        );
      } else {
        // Create new note
        await _noteService.createNote(
          content: note.content,
          notebookId: note.notebookId,
        );
      }

      // Download associated images if they exist
      for (String imageName in note.images) {
        await _downloadImage(note.id, imageName);
      }

      // print('Successfully downloaded note: $noteId');
    } catch (e) {
      // print('Error downloading note $noteId: $e');
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
      // print('Error getting possible years: $e');
      // Default to a few recent years
      int currentYear = DateTime.now().year;
      return [currentYear, currentYear - 1, currentYear - 2];
    }
  }

  Future<void> _uploadImage(String noteId, String imageName) async {
    try {
      // Get the local image path
      final appDir = await getApplicationDocumentsDirectory();
      String imagePath = path.join(appDir.path, 'images', noteId, imageName);

      File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        // Calculate the destination path on WebDAV
        String imageYearPath = _getYearFromTimestamp(DateTime.now());
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

        // print('Successfully uploaded image: $destinationPath');
      } else {
        // print('Local image does not exist: $imagePath');
      }
    } catch (e) {
      // print('Error uploading image for note $noteId: $e');
    }
  }

  Future<void> _downloadImage(String noteId, String imageName) async {
    try {
      // Calculate the source path on WebDAV
      String imageYearPath = _getYearFromTimestamp(DateTime.now());
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

      // print('Successfully downloaded image: $sourcePath to $localImageFilePath');
    } catch (e) {
      // print('Error downloading image for note $noteId: $e');
    }
  }

  Future<void> _updateSyncFile(Map<String, SyncStatus> syncStatusMap) async {
    try {
      Map<String, String> syncData = {};

      for (final entry in syncStatusMap.entries) {
        String noteId = entry.key;
        SyncStatus status = entry.value;

        // Use the newer timestamp (local or remote) if there was a sync operation
        if (status.needsUpload || status.needsDownload) {
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

      // print('Sync file updated successfully');
    } catch (e) {
      // print('Error updating sync file: $e');
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
    // Client doesn't need explicit closing
  }
}