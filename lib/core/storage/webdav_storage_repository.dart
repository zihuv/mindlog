import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:think_tract_flutter/features/journal/domain/entities/journal_entry.dart';
import 'package:think_tract_flutter/core/storage/interfaces/storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebDAVStorageRepository implements StorageRepository {
  final String serverUrl;
  final String username;
  final String password;
  final String remotePath;
  late webdav.Client _client;
  SharedPreferences? _prefs;

  WebDAVStorageRepository({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.remotePath = '/think_track/',
  });

  @override
  Future<void> initialize() async {
    // Initialize both WebDAV client and local SharedPreferences as fallback
    _client = webdav.newClient(
      serverUrl,
      user: username,
      password: password,
      debug: false,
    );
    
    _prefs = await SharedPreferences.getInstance();
    
    // Ensure the remote directory exists
    try {
      await _client.mkdir(remotePath);
    } catch (e) {
      // Directory might already exist, which is fine
    }
  }

  @override
  Future<List<JournalEntry>> getAllJournalEntries() async {
    try {
      // Try to fetch from WebDAV first
      final remoteFile = await _client.read('${remotePath}journal_entries.json');
      final jsonString = String.fromCharCodes(remoteFile);
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.map((json) => _fromJson(json)).toList();
    } catch (e) {
      // If WebDAV fails, fall back to local storage
      print('WebDAV fetch failed: $e, falling back to local storage');
      final jsonString = _prefs!.getString('journal_entries') ?? '[]';
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => _fromJson(json)).toList();
    }
  }

  @override
  Future<JournalEntry?> getJournalEntryById(int id) async {
    final allEntries = await getAllJournalEntries();
    final entry = allEntries.firstWhere(
          (entry) => entry.id == id,
      orElse: () => JournalEntry(id: 0, content: '', dateTime: DateTime.now(), mood: ''),
    );
    return entry.id == 0 ? null : entry;
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesByDate(DateTime date) async {
    final allEntries = await getAllJournalEntries();

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day + 1);

    return allEntries
        .where(
          (entry) =>
          entry.dateTime.isAfter(startOfDay) &&
              entry.dateTime.isBefore(endOfDay),
    )
        .toList();
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    try {
      // Fetch all entries from WebDAV
      List<JournalEntry> allEntries = [];
      try {
        final remoteFile = await _client.read('${remotePath}journal_entries.json');
        final jsonString = String.fromCharCodes(remoteFile);
        final List<dynamic> jsonList = json.decode(jsonString);
        allEntries = jsonList.map((json) => _fromJson(json)).toList();
      } catch (e) {
        // If file doesn't exist, start with empty list
        allEntries = [];
      }

      // Update or add the entry
      final existingIndex = allEntries.indexWhere((e) => e.id == entry.id);
      if (existingIndex != -1) {
        allEntries[existingIndex] = entry;
      } else {
        allEntries.add(entry);
      }

      // Save back to WebDAV
      final jsonString = json.encode(
        allEntries.map((entry) => _toJson(entry)).toList(),
      );
      
      // Create a temporary file to write from
      final tempFilePath = await _createTempFile(jsonString);
      await _client.writeFromFile(tempFilePath, '${remotePath}journal_entries.json');
      
      // Also save to local storage as backup
      await _prefs!.setString('journal_entries', jsonString);
    } catch (e) {
      print('WebDAV save failed: $e, saving to local storage only');
      // Fallback to saving only to local storage
      final allEntries = await _getAllLocalEntries();
      final existingIndex = allEntries.indexWhere((e) => e.id == entry.id);
      if (existingIndex != -1) {
        allEntries[existingIndex] = entry;
      } else {
        allEntries.add(entry);
      }
      final jsonString = json.encode(
        allEntries.map((entry) => _toJson(entry)).toList(),
      );
      await _prefs!.setString('journal_entries', jsonString);
    }
  }

  @override
  Future<void> updateJournalEntry(JournalEntry entry) async {
    await saveJournalEntry(entry);
  }

  @override
  Future<void> deleteJournalEntry(int id) async {
    try {
      // Fetch all entries from WebDAV
      List<JournalEntry> allEntries = [];
      try {
        final remoteFile = await _client.read('${remotePath}journal_entries.json');
        final jsonString = String.fromCharCodes(remoteFile);
        final List<dynamic> jsonList = json.decode(jsonString);
        allEntries = jsonList.map((json) => _fromJson(json)).toList();
      } catch (e) {
        // If file doesn't exist, start with empty list
        allEntries = [];
      }

      // Remove the entry
      allEntries.removeWhere((entry) => entry.id == id);

      // Save back to WebDAV
      final jsonString = json.encode(
        allEntries.map((entry) => _toJson(entry)).toList(),
      );
      
      // Create a temporary file to write from
      final tempFilePath = await _createTempFile(jsonString);
      await _client.writeFromFile(tempFilePath, '${remotePath}journal_entries.json');
      
      // Also update local storage as backup
      await _prefs!.setString('journal_entries', jsonString);
    } catch (e) {
      print('WebDAV delete failed: $e, updating local storage only');
      // Fallback to updating only local storage
      final allEntries = await _getAllLocalEntries();
      allEntries.removeWhere((entry) => entry.id == id);
      final jsonString = json.encode(
        allEntries.map((entry) => _toJson(entry)).toList(),
      );
      await _prefs!.setString('journal_entries', jsonString);
    }
  }

  @override
  Future<void> close() async {
    // No specific close action needed
  }

  Future<String> _createTempFile(String data) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = path.join(tempDir.path, 'temp_journal.json');
    final tempFile = File(tempPath);
    await tempFile.writeAsString(data);
    return tempFile.path;
  }

  Map<String, dynamic> _toJson(JournalEntry entry) {
    return {
      'id': entry.id,
      'content': entry.content,
      'dateTime': entry.dateTime.toIso8601String(),
      'mood': entry.mood,
    };
  }

  JournalEntry _fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      content: json['content'],
      dateTime: DateTime.parse(json['dateTime']),
      mood: json['mood'],
    );
  }

  Future<List<JournalEntry>> _getAllLocalEntries() async {
    final jsonString = _prefs!.getString('journal_entries') ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => _fromJson(json)).toList();
  }
}