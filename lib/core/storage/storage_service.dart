import 'package:mindlog/core/storage/interfaces/storage_repository.dart';
import 'package:mindlog/core/storage/simple_storage_repository.dart';
import 'package:mindlog/features/journal/domain/entities/journal_entry.dart';

class StorageService {
  StorageRepository? _currentRepository;

  static StorageService? _instance;
  static StorageService get instance {
    _instance ??= StorageService();
    return _instance!;
  }

  StorageRepository get repository {
    if (_currentRepository == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _currentRepository!;
  }

  Future<void> init() async {
    await _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    // Ensure previous repository is closed
    if (_currentRepository != null) {
      await _currentRepository!.close();
    }

    // Create local storage repository
    _currentRepository = SimpleStorageRepository();
    await _currentRepository!.initialize();
  }

  // Proxy all StorageRepository methods to current repository
  Future<void> initialize() => repository.initialize();
  Future<List<JournalEntry>> getAllJournalEntries() => repository.getAllJournalEntries();
  Future<JournalEntry?> getJournalEntryById(int id) => repository.getJournalEntryById(id);
  Future<List<JournalEntry>> getJournalEntriesByDate(DateTime date) => repository.getJournalEntriesByDate(date);
  Future<void> saveJournalEntry(JournalEntry entry) => repository.saveJournalEntry(entry);
  Future<void> updateJournalEntry(JournalEntry entry) => repository.updateJournalEntry(entry);
  Future<void> deleteJournalEntry(int id) => repository.deleteJournalEntry(id);
  Future<void> close() => repository.close();
}