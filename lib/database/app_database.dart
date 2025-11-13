import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Data classes for our note
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()(); // Contains the note content for search
  DateTimeColumn get time => dateTime()();
  DateTimeColumn get lastModified => dateTime()();
  TextColumn get imageName => text().map(const ListToStringConverter())(); // JSON string
  TextColumn get audioName => text().map(const ListToStringConverter())(); // JSON string
  TextColumn get videoName => text().map(const ListToStringConverter())(); // JSON string
  TextColumn get tags => text().map(const ListToStringConverter())(); // JSON string
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

// Converter to store List<String> as JSON in the database
class ListToStringConverter extends TypeConverter<List<String>, String> {
  const ListToStringConverter();

  List<String> mapToDart(String? fromData) {
    if (fromData == null) return <String>[];
    return fromData.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  String? mapToSql(List<String>? value) {
    if (value == null) return null;
    return value.join(',');
  }
  
  @override
  List<String> fromSql(String? fromDb) {
    if (fromDb == null) return <String>[];
    return fromDb.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
  
  @override
  String toSql(List<String>? value) {
    if (value == null) return '';
    return value.join(',');
  }
}

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'mindlog_db.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}