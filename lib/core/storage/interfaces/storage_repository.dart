import 'package:mindlog/features/journal/domain/entities/journal_entry.dart';

abstract class StorageRepository {
  /// Initialize the storage
  Future<void> initialize();

  /// Get all journal entries
  Future<List<JournalEntry>> getAllJournalEntries();

  /// Get journal entry by id
  Future<JournalEntry?> getJournalEntryById(int id);

  /// Get journal entries for a specific date
  Future<List<JournalEntry>> getJournalEntriesByDate(DateTime date);

  /// Save a journal entry
  Future<void> saveJournalEntry(JournalEntry entry);

  /// Update a journal entry
  Future<void> updateJournalEntry(JournalEntry entry);

  /// Delete a journal entry
  Future<void> deleteJournalEntry(int id);

  /// Close the storage connection
  Future<void> close();
}
