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
  static const VerificationMeta _notebookIdMeta = const VerificationMeta(
    'notebookId',
  );
  @override
  late final GeneratedColumn<String> notebookId = GeneratedColumn<String>(
    'notebook_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
    notebookId,
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
    if (data.containsKey('notebook_id')) {
      context.handle(
        _notebookIdMeta,
        notebookId.isAcceptableOrUnknown(data['notebook_id']!, _notebookIdMeta),
      );
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
      notebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notebook_id'],
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
  final String? notebookId;
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
    this.notebookId,
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
    if (!nullToAbsent || notebookId != null) {
      map['notebook_id'] = Variable<String>(notebookId);
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
      notebookId: notebookId == null && nullToAbsent
          ? const Value.absent()
          : Value(notebookId),
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
      notebookId: serializer.fromJson<String?>(json['notebookId']),
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
      'notebookId': serializer.toJson<String?>(notebookId),
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
    Value<String?> notebookId = const Value.absent(),
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
    notebookId: notebookId.present ? notebookId.value : this.notebookId,
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
      notebookId: data.notebookId.present
          ? data.notebookId.value
          : this.notebookId,
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
          ..write('notebookId: $notebookId, ')
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
    notebookId,
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
          other.notebookId == this.notebookId &&
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
  final Value<String?> notebookId;
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
    this.notebookId = const Value.absent(),
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
    this.notebookId = const Value.absent(),
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
    Expression<String>? notebookId,
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
      if (notebookId != null) 'notebook_id': notebookId,
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
    Value<String?>? notebookId,
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
      notebookId: notebookId ?? this.notebookId,
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
    if (notebookId.present) {
      map['notebook_id'] = Variable<String>(notebookId.value);
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
          ..write('notebookId: $notebookId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotebooksTable extends Notebooks
    with TableInfo<$NotebooksTable, Notebook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverImageMeta = const VerificationMeta(
    'coverImage',
  );
  @override
  late final GeneratedColumn<String> coverImage = GeneratedColumn<String>(
    'cover_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('standard'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    coverImage,
    type,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notebook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_image')) {
      context.handle(
        _coverImageMeta,
        coverImage.isAcceptableOrUnknown(data['cover_image']!, _coverImageMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Notebook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notebook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      coverImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $NotebooksTable createAlias(String alias) {
    return $NotebooksTable(attachedDatabase, alias);
  }
}

class Notebook extends DataClass implements Insertable<Notebook> {
  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final String type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Notebook({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    required this.type,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverImage != null) {
      map['cover_image'] = Variable<String>(coverImage);
    }
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  NotebooksCompanion toCompanion(bool nullToAbsent) {
    return NotebooksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverImage: coverImage == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImage),
      type: Value(type),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Notebook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notebook(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      coverImage: serializer.fromJson<String?>(json['coverImage']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'coverImage': serializer.toJson<String?>(coverImage),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Notebook copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> coverImage = const Value.absent(),
    String? type,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Notebook(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    coverImage: coverImage.present ? coverImage.value : this.coverImage,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Notebook copyWithCompanion(NotebooksCompanion data) {
    return Notebook(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverImage: data.coverImage.present
          ? data.coverImage.value
          : this.coverImage,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notebook(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverImage: $coverImage, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    coverImage,
    type,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notebook &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.coverImage == this.coverImage &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotebooksCompanion extends UpdateCompanion<Notebook> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> coverImage;
  final Value<String> type;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const NotebooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.coverImage = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotebooksCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.coverImage = const Value.absent(),
    this.type = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Notebook> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? coverImage,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (coverImage != null) 'cover_image': coverImage,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotebooksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? coverImage,
    Value<String>? type,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return NotebooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverImage.present) {
      map['cover_image'] = Variable<String>(coverImage.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverImage: $coverImage, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NotebooksTable notebooks = $NotebooksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [notes, notebooks];
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
      Value<String?> notebookId,
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
      Value<String?> notebookId,
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

  ColumnFilters<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => ColumnFilters(column),
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

  ColumnOrderings<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
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

  GeneratedColumn<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => column,
  );

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
                Value<String?> notebookId = const Value.absent(),
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
                notebookId: notebookId,
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
                Value<String?> notebookId = const Value.absent(),
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
                notebookId: notebookId,
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
typedef $$NotebooksTableCreateCompanionBuilder =
    NotebooksCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      Value<String?> coverImage,
      Value<String> type,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$NotebooksTableUpdateCompanionBuilder =
    NotebooksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String?> coverImage,
      Value<String> type,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$NotebooksTableFilterComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImage => $composableBuilder(
    column: $table.coverImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotebooksTableOrderingComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImage => $composableBuilder(
    column: $table.coverImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotebooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverImage => $composableBuilder(
    column: $table.coverImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotebooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotebooksTable,
          Notebook,
          $$NotebooksTableFilterComposer,
          $$NotebooksTableOrderingComposer,
          $$NotebooksTableAnnotationComposer,
          $$NotebooksTableCreateCompanionBuilder,
          $$NotebooksTableUpdateCompanionBuilder,
          (Notebook, BaseReferences<_$AppDatabase, $NotebooksTable, Notebook>),
          Notebook,
          PrefetchHooks Function()
        > {
  $$NotebooksTableTableManager(_$AppDatabase db, $NotebooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverImage = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotebooksCompanion(
                id: id,
                title: title,
                description: description,
                coverImage: coverImage,
                type: type,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> coverImage = const Value.absent(),
                Value<String> type = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotebooksCompanion.insert(
                id: id,
                title: title,
                description: description,
                coverImage: coverImage,
                type: type,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotebooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotebooksTable,
      Notebook,
      $$NotebooksTableFilterComposer,
      $$NotebooksTableOrderingComposer,
      $$NotebooksTableAnnotationComposer,
      $$NotebooksTableCreateCompanionBuilder,
      $$NotebooksTableUpdateCompanionBuilder,
      (Notebook, BaseReferences<_$AppDatabase, $NotebooksTable, Notebook>),
      Notebook,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db, _db.notebooks);
}
