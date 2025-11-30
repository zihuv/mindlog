import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:mindlog/features/notebooks/notebook_service.dart';
import 'log_util.dart';

class NotebookSyncManager {
  static const String _notebooksDir = 'Notebook';
  static const String _syncFileName = 'notebook_sync.json';

  webdav.Client? _client;
  late String _rootPath;
  late NotebookService _notebookService;

  NotebookSyncManager({NotebookService? notebookService}) {
    _notebookService = notebookService ?? NotebookService.instance;
  }

  Future<void> initClient(String baseUrl, String username, String password, String folderName) async {
    _rootPath = '/$folderName/';

    _client = webdav.newClient(
      baseUrl,
      user: username,
      password: password,
      debug: false,
    );

    _client?.setHeaders({
      'accept-charset': 'utf-8',
      'Content-Type': 'application/json',
    });

    logger.info('Notebook sync client initialized with URL: $baseUrl and folder: $folderName');
  }

  Future<void> sync() async {
    if (_client == null) {
      logger.error('WebDAV client not initialized for notebook sync');
      throw Exception('WebDAV client not initialized. Call initClient() first.');
    }

    try {
      logger.info('Starting notebook WebDAV sync process');
      
      // Ensure the notebooks directory exists
      await _ensureNotebooksDirectory();

      // Load the local notebooks
      await _notebookService.init();
      List<Notebook> localNotebooks = await _notebookService.getAllNotebooks();
      logger.info('Found ${localNotebooks.length} local notebooks');

      // Download notebook sync file from WebDAV
      Map<String, dynamic> remoteSyncData = await _downloadSyncFile();

      // Calculate sync status for each notebook
      Map<String, NotebookSyncStatus> syncStatusMap = await _calculateSyncStatus(
        localNotebooks,
        remoteSyncData,
      );

      // Process sync operations
      await _processSyncOperations(syncStatusMap, localNotebooks);

      // Update notebook sync.json after sync
      await _updateSyncFile(syncStatusMap);
      logger.info('Notebook WebDAV sync process completed successfully');
    } catch (e, s) {
      logger.error('Error during notebook sync', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> _ensureNotebooksDirectory() async {
    final notebooksPath = '$_rootPath$_notebooksDir/';
    logger.debug('Ensuring notebooks directory exists: $notebooksPath');
    
    try {
      await _client!.mkdirAll(notebooksPath);
      logger.debug('Created/verified notebooks directory: $notebooksPath');
    } catch (e) {
      logger.warning('Failed to create notebooks directory $notebooksPath (may already exist)');
    }
  }

  Future<Map<String, dynamic>> _downloadSyncFile() async {
    try {
      logger.debug('Downloading notebook sync file from WebDAV');
      final response = await _client!.read(_rootPath + _syncFileName);
      if (response.isNotEmpty) {
        String remoteSyncContent = utf8.decode(response);
        logger.debug('Notebook sync file downloaded successfully');
        return jsonDecode(remoteSyncContent);
      }
      logger.debug('Notebook sync file is empty');
      return {};
    } catch (e) {
      logger.warning('Notebook sync file does not exist on server, starting fresh');
      return {};
    }
  }

  Future<Map<String, NotebookSyncStatus>> _calculateSyncStatus(
    List<Notebook> localNotebooks,
    Map<String, dynamic> remoteSyncData,
  ) async {
    Map<String, NotebookSyncStatus> syncStatusMap = {};

    // Check all local notebooks
    for (final notebook in localNotebooks) {
      String notebookId = notebook.id;
      String localTimestamp = _formatTimestamp(
        notebook.updateTime ?? notebook.createTime,
      );
      String? remoteTimestamp = remoteSyncData[notebookId] as String?;

      // Determine if the notebook needs to be uploaded, downloaded, or both
      bool needsUpload = false;
      bool needsDownload = false;

      if (remoteTimestamp == null) {
        // Notebook doesn't exist on server, needs upload
        needsUpload = true;
      } else if (remoteTimestamp == 'delete') {
        // Notebook was deleted on server, but exists locally
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

      syncStatusMap[notebookId] = NotebookSyncStatus(
        needsUpload: needsUpload,
        needsDownload: needsDownload,
        localTimestamp: localTimestamp,
        remoteTimestamp: remoteTimestamp,
      );
    }

    // Check for notebooks that exist remotely but not locally (for deletion)
    for (final entry in remoteSyncData.entries) {
      String notebookId = entry.key;
      String? remoteStatus = entry.value as String?;

      if (remoteStatus == 'delete') {
        // If the notebook was deleted remotely, mark it for local deletion
        if (!syncStatusMap.containsKey(notebookId)) {
          syncStatusMap[notebookId] = NotebookSyncStatus(
            needsUpload: false,
            needsDownload: false,
            localTimestamp: '0',
          );
        }
      } else if (remoteStatus != null && !syncStatusMap.containsKey(notebookId)) {
        // Notebook exists remotely but not locally, needs download
        syncStatusMap[notebookId] = NotebookSyncStatus(
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
    Map<String, NotebookSyncStatus> syncStatusMap,
    List<Notebook> localNotebooks,
  ) async {
    // Process downloads first (notebooks that need to be downloaded from server)
    for (final entry in syncStatusMap.entries) {
      String notebookId = entry.key;
      NotebookSyncStatus status = entry.value;

      if (status.needsDownload) {
        await _downloadNotebook(notebookId);
      }
    }

    // Process uploads (notebooks that need to be uploaded to server)
    for (final entry in syncStatusMap.entries) {
      String notebookId = entry.key;
      NotebookSyncStatus status = entry.value;

      if (status.needsUpload) {
        // Find the local notebook
        Notebook? localNotebook;
        try {
          localNotebook = localNotebooks.firstWhere((notebook) => notebook.id == notebookId);
        } catch (e) {
          // Notebook not found in localNotebooks list
          localNotebook = null;
        }

        if (localNotebook != null) {
          await _uploadNotebook(localNotebook);
        } else if (status.remoteTimestamp != 'delete') {
          // If local notebook doesn't exist but remote status isn't 'delete',
          // then we should remove it from sync status (it might have been deleted locally)
        }
      }
    }
  }

  Future<void> _uploadNotebook(Notebook notebook) async {
    try {
      logger.debug('Uploading notebook: ${notebook.id}');
      
      // Upload the notebook JSON file
      String notebookJson = jsonEncode(notebook.toJson());
      String notebookPath = '$_rootPath$_notebooksDir/${notebook.id}.json';

      _client!.setHeaders({
        'accept-charset': 'utf-8',
        'Content-Type': 'application/json',
      });

      await _client!.write(
        notebookPath,
        Uint8List.fromList(utf8.encode(notebookJson))
      );

      logger.info('Successfully uploaded notebook: ${notebook.id}');
    } catch (e, s) {
      logger.error('Error uploading notebook ${notebook.id}', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> _downloadNotebook(String notebookId) async {
    try {
      logger.debug('Downloading notebook: $notebookId');
      
      String path = '$_rootPath$_notebooksDir/$notebookId.json';
      List<int> bytes;
      
      try {
        bytes = await _client!.read(path);
      } catch (e) {
        // Notebook doesn't exist on server, might have been deleted
        Notebook? existingNotebook = await _notebookService.getNotebookById(notebookId);
        if (existingNotebook != null) {
          await _notebookService.deleteNotebook(notebookId);
          logger.info('Notebook deleted locally as it was removed from server: $notebookId');
        }
        return;
      }

      String notebookContent = utf8.decode(Uint8List.fromList(bytes));
      Map<String, dynamic> notebookData = jsonDecode(notebookContent);
      Notebook notebook = Notebook.fromJson(notebookData);

      // Check if notebook exists locally
      Notebook? existingNotebook = await _notebookService.getNotebookById(notebookId);

      if (existingNotebook != null) {
        // Update existing notebook - use copyWith to update the notebook
        Notebook updatedNotebook = existingNotebook.copyWith(
          title: notebook.title,
          description: notebook.description,
          coverImage: notebook.coverImage,
          type: notebook.type,
          updateTime: notebook.updateTime,
        );
        await _notebookService.updateNotebook(updatedNotebook);
        logger.debug('Updated existing notebook: $notebookId');
      } else {
        // Create new notebook
        await _notebookService.saveNotebook(notebook);
        logger.debug('Created new notebook: $notebookId');
      }

      logger.info('Successfully downloaded notebook: $notebookId');
    } catch (e, s) {
      logger.error('Error downloading notebook $notebookId', error: e, stackTrace: s);
    }
  }

  Future<void> _updateSyncFile(Map<String, NotebookSyncStatus> syncStatusMap) async {
    try {
      logger.debug('Updating notebook sync file with ${syncStatusMap.length} entries');
      Map<String, String> syncData = {};

      for (final entry in syncStatusMap.entries) {
        String notebookId = entry.key;
        NotebookSyncStatus status = entry.value;

        // Use the newer timestamp (local or remote) if there was a sync operation
        if (status.needsUpload || status.needsDownload) {
          syncData[notebookId] = status.localTimestamp;
        } else {
          // Use the original remote timestamp if no sync occurred
          syncData[notebookId] = status.remoteTimestamp ?? status.localTimestamp;
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

      logger.info('Notebook sync file updated successfully with ${syncData.length} entries');
    } catch (e, s) {
      logger.error('Error updating notebook sync file', error: e, stackTrace: s);
      rethrow;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  void dispose() {
    _client = null;
  }
}

class NotebookSyncStatus {
  final bool needsUpload;
  final bool needsDownload;
  final String localTimestamp;
  final String? remoteTimestamp;

  NotebookSyncStatus({
    required this.needsUpload,
    required this.needsDownload,
    required this.localTimestamp,
    this.remoteTimestamp,
  });
}