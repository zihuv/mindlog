import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:get/get.dart' hide Value;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:mindlog/utils/log_util.dart';

part 'app_database.g.dart';

// Data classes for our note
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()(); // Contains the note content for search
  DateTimeColumn get createTime => dateTime()();
  DateTimeColumn get updateTime => dateTime()();
  TextColumn get imageName =>
      text().map(const ListToStringConverter())(); // JSON string
  TextColumn get audioName =>
      text().map(const ListToStringConverter())(); // JSON string
  TextColumn get videoName =>
      text().map(const ListToStringConverter())(); // JSON string
  TextColumn get notebookId => text().nullable()(); // Foreign key to notebook
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

// Data class for notebook
class Notebooks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverImage => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('standard'))();
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createTime => dateTime()();
  DateTimeColumn get updateTime => dateTime().nullable()();
}

// Converter to store List<String> as JSON in the database
class ListToStringConverter extends TypeConverter<List<String>, String> {
  const ListToStringConverter();

  List<String> mapToDart(String? fromData) {
    if (fromData == null) return <String>[];
    return fromData
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String? mapToSql(List<String>? value) {
    if (value == null) return null;
    return value.join(',');
  }

  @override
  List<String> fromSql(String? fromDb) {
    if (fromDb == null) return <String>[];
    return fromDb
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  String toSql(List<String>? value) {
    if (value == null) return '';
    return value.join(',');
  }
}

@DriftDatabase(tables: [Notes, Notebooks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2 && to >= 2) {
        try {
          // Add sort_index column to existing Notebooks table
          await m.addColumn(notebooks, notebooks.sortIndex);
        } catch (e) {
          // Column might already exist in some cases (e.g., macOS), so we catch and continue
          logger.info('Column sort_index may already exist: $e');
        }

        // For existing databases (from < 2), populate sort_index with 0 initially
        // Then the service will handle the proper migration later
      }
    },
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'mindlog_db.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

// Singleton instance to ensure only one database instance exists
class DatabaseProvider extends GetxService {
  static DatabaseProvider get instance => Get.find();

  AppDatabase? _database;

  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  // Close the database when the app is done with it
  Future<void> close() async {
    if (_database != null) {
      try {
        await _database!.close();
      } catch (e) {
        logger.error('Error closing database: $e');
      }
      _database = null;
    }
  }

  // Reset the database instance to force reinitialization
  Future<void> reset() async {
    // First try to close the existing connection
    if (_database != null) {
      try {
        await _database!.close();
      } catch (e) {
        logger.error('Error closing database during reset: $e');
      }
      _database = null;
    }
  }
}