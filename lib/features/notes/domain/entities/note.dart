import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final String? visibility; // 'PUBLIC', 'PRIVATE', 'LIMITED'
  final String? notebookId; // Foreign key to notebook
  final List<String> tags;
  final List<String> images;
  final List<String> videos;
  final List<String> audios;
  final Map<int, bool>
  checklistStates; // Tracks the checked/unchecked state of checkboxes

  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.visibility = 'PRIVATE',
    this.notebookId,
    this.tags = const [],
    this.images = const [],
    this.videos = const [],
    this.audios = const [],
    this.checklistStates = const {},
  });

  @override
  List<Object?> get props => [
    id,
    content,
    createdAt,
    updatedAt,
    isPinned,
    visibility,
    notebookId,
    tags,
    images,
    videos,
    audios,
    checklistStates,
  ];

  Note copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? visibility,
    String? notebookId,
    List<String>? tags,
    List<String>? images,
    List<String>? videos,
    List<String>? audios,
    Map<int, bool>? checklistStates,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      visibility: visibility ?? this.visibility,
      notebookId: notebookId ?? this.notebookId,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      audios: audios ?? this.audios,
      checklistStates: checklistStates ?? this.checklistStates,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert int keys to string for JSON serialization
    Map<String, bool> serializedChecklistStates = {};
    checklistStates.forEach((key, value) {
      serializedChecklistStates[key.toString()] = value;
    });

    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPinned': isPinned,
      'visibility': visibility,
      'notebookId': notebookId,
      'tags': tags,
      'images': images,
      'videos': videos,
      'audios': audios,
      'checklistStates': serializedChecklistStates,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    // Convert string keys back to int when deserializing
    Map<int, bool> deserializedChecklistStates = {};
    final checklistJson = json['checklistStates'] ?? {};
    if (checklistJson is Map) {
      checklistJson.forEach((key, value) {
        if (key is String) {
          deserializedChecklistStates[int.tryParse(key) ?? 0] = value as bool;
        } else if (key is int) {
          deserializedChecklistStates[key] = value as bool;
        }
      });
    }

    return Note(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isPinned: json['isPinned'] ?? false,
      visibility: json['visibility'] ?? 'PRIVATE',
      notebookId: json['notebookId'],
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      audios: List<String>.from(json['audios'] ?? []),
      checklistStates: deserializedChecklistStates,
    );
  }
}
