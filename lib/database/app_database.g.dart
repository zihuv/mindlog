// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> imageName =
      GeneratedColumn<String>(
        'image_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($NotesTable.$converterimageName);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> audioName =
      GeneratedColumn<String>(
        'audio_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($NotesTable.$converteraudioName);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> videoName =
      GeneratedColumn<String>(
        'video_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($NotesTable.$convertervideoName);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($NotesTable.$convertertags);
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    time,
    lastModified,
    imageName,
    audioName,
    videoName,
    tags,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      imageName: $NotesTable.$converterimageName.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}image_name'],
        )!,
      ),
      audioName: $NotesTable.$converteraudioName.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}audio_name'],
        )!,
      ),
      videoName: $NotesTable.$convertervideoName.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}video_name'],
        )!,
      ),
      tags: $NotesTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterimageName =
      const ListToStringConverter();
  static TypeConverter<List<String>, String> $converteraudioName =
      const ListToStringConverter();
  static TypeConverter<List<String>, String> $convertervideoName =
      const ListToStringConverter();
  static TypeConverter<List<String>, String> $convertertags =
      const ListToStringConverter();
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String content;
  final DateTime time;
  final DateTime lastModified;
  final List<String> imageName;
  final List<String> audioName;
  final List<String> videoName;
  final List<String> tags;
  final bool isDeleted;
  const Note({
    required this.id,
    required this.content,
    required this.time,
    required this.lastModified,
    required this.imageName,
    required this.audioName,
    required this.videoName,
    required this.tags,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    map['time'] = Variable<DateTime>(time);
    map['last_modified'] = Variable<DateTime>(lastModified);
    {
      map['image_name'] = Variable<String>(
        $NotesTable.$converterimageName.toSql(imageName),
      );
    }
    {
      map['audio_name'] = Variable<String>(
        $NotesTable.$converteraudioName.toSql(audioName),
      );
    }
    {
      map['video_name'] = Variable<String>(
        $NotesTable.$convertervideoName.toSql(videoName),
      );
    }
    {
      map['tags'] = Variable<String>($NotesTable.$convertertags.toSql(tags));
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      content: Value(content),
      time: Value(time),
      lastModified: Value(lastModified),
      imageName: Value(imageName),
      audioName: Value(audioName),
      videoName: Value(videoName),
      tags: Value(tags),
      isDeleted: Value(isDeleted),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      time: serializer.fromJson<DateTime>(json['time']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      imageName: serializer.fromJson<List<String>>(json['imageName']),
      audioName: serializer.fromJson<List<String>>(json['audioName']),
      videoName: serializer.fromJson<List<String>>(json['videoName']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'time': serializer.toJson<DateTime>(time),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'imageName': serializer.toJson<List<String>>(imageName),
      'audioName': serializer.toJson<List<String>>(audioName),
      'videoName': serializer.toJson<List<String>>(videoName),
      'tags': serializer.toJson<List<String>>(tags),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Note copyWith({
    String? id,
    String? content,
    DateTime? time,
    DateTime? lastModified,
    List<String>? imageName,
    List<String>? audioName,
    List<String>? videoName,
    List<String>? tags,
    bool? isDeleted,
  }) => Note(
    id: id ?? this.id,
    content: content ?? this.content,
    time: time ?? this.time,
    lastModified: lastModified ?? this.lastModified,
    imageName: imageName ?? this.imageName,
    audioName: audioName ?? this.audioName,
    videoName: videoName ?? this.videoName,
    tags: tags ?? this.tags,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      time: data.time.present ? data.time.value : this.time,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      imageName: data.imageName.present ? data.imageName.value : this.imageName,
      audioName: data.audioName.present ? data.audioName.value : this.audioName,
      videoName: data.videoName.present ? data.videoName.value : this.videoName,
      tags: data.tags.present ? data.tags.value : this.tags,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('time: $time, ')
          ..write('lastModified: $lastModified, ')
          ..write('imageName: $imageName, ')
          ..write('audioName: $audioName, ')
          ..write('videoName: $videoName, ')
          ..write('tags: $tags, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    time,
    lastModified,
    imageName,
    audioName,
    videoName,
    tags,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.content == this.content &&
          other.time == this.time &&
          other.lastModified == this.lastModified &&
          other.imageName == this.imageName &&
          other.audioName == this.audioName &&
          other.videoName == this.videoName &&
          other.tags == this.tags &&
          other.isDeleted == this.isDeleted);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> content;
  final Value<DateTime> time;
  final Value<DateTime> lastModified;
  final Value<List<String>> imageName;
  final Value<List<String>> audioName;
  final Value<List<String>> videoName;
  final Value<List<String>> tags;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.time = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.imageName = const Value.absent(),
    this.audioName = const Value.absent(),
    this.videoName = const Value.absent(),
    this.tags = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String content,
    required DateTime time,
    required DateTime lastModified,
    required List<String> imageName,
    required List<String> audioName,
    required List<String> videoName,
    required List<String> tags,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content),
       time = Value(time),
       lastModified = Value(lastModified),
       imageName = Value(imageName),
       audioName = Value(audioName),
       videoName = Value(videoName),
       tags = Value(tags);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<DateTime>? time,
    Expression<DateTime>? lastModified,
    Expression<String>? imageName,
    Expression<String>? audioName,
    Expression<String>? videoName,
    Expression<String>? tags,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (time != null) 'time': time,
      if (lastModified != null) 'last_modified': lastModified,
      if (imageName != null) 'image_name': imageName,
      if (audioName != null) 'audio_name': audioName,
      if (videoName != null) 'video_name': videoName,
      if (tags != null) 'tags': tags,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<DateTime>? time,
    Value<DateTime>? lastModified,
    Value<List<String>>? imageName,
    Value<List<String>>? audioName,
    Value<List<String>>? videoName,
    Value<List<String>>? tags,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      time: time ?? this.time,
      lastModified: lastModified ?? this.lastModified,
      imageName: imageName ?? this.imageName,
      audioName: audioName ?? this.audioName,
      videoName: videoName ?? this.videoName,
      tags: tags ?? this.tags,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (imageName.present) {
      map['image_name'] = Variable<String>(
        $NotesTable.$converterimageName.toSql(imageName.value),
      );
    }
    if (audioName.present) {
      map['audio_name'] = Variable<String>(
        $NotesTable.$converteraudioName.toSql(audioName.value),
      );
    }
    if (videoName.present) {
      map['video_name'] = Variable<String>(
        $NotesTable.$convertervideoName.toSql(videoName.value),
      );
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $NotesTable.$convertertags.toSql(tags.value),
      );
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('time: $time, ')
          ..write('lastModified: $lastModified, ')
          ..write('imageName: $imageName, ')
          ..write('audioName: $audioName, ')
          ..write('videoName: $videoName, ')
          ..write('tags: $tags, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotesTable notes = $NotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [notes];
}

typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      required String id,
      required String content,
      required DateTime time,
      required DateTime lastModified,
      required List<String> imageName,
      required List<String> audioName,
      required List<String> videoName,
      required List<String> tags,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<DateTime> time,
      Value<DateTime> lastModified,
      Value<List<String>> imageName,
      Value<List<String>> audioName,
      Value<List<String>> videoName,
      Value<List<String>> tags,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get imageName => $composableBuilder(
    column: $table.imageName,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get audioName => $composableBuilder(
    column: $table.audioName,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get videoName => $composableBuilder(
    column: $table.videoName,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageName => $composableBuilder(
    column: $table.imageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioName => $composableBuilder(
    column: $table.audioName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoName => $composableBuilder(
    column: $table.videoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get imageName =>
      $composableBuilder(column: $table.imageName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get audioName =>
      $composableBuilder(column: $table.audioName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get videoName =>
      $composableBuilder(column: $table.videoName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
          Note,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<List<String>> imageName = const Value.absent(),
                Value<List<String>> audioName = const Value.absent(),
                Value<List<String>> videoName = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                content: content,
                time: time,
                lastModified: lastModified,
                imageName: imageName,
                audioName: audioName,
                videoName: videoName,
                tags: tags,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String content,
                required DateTime time,
                required DateTime lastModified,
                required List<String> imageName,
                required List<String> audioName,
                required List<String> videoName,
                required List<String> tags,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                content: content,
                time: time,
                lastModified: lastModified,
                imageName: imageName,
                audioName: audioName,
                videoName: videoName,
                tags: tags,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
      Note,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
}
