import 'package:equatable/equatable.dart';

class Memo extends Equatable {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final String? visibility; // 'PUBLIC', 'PRIVATE', 'LIMITED'
  final List<String> tags;
  final List<String> images;
  final List<String> videos;
  final List<String> audios;
  final Map<int, bool>
  checklistStates; // Tracks the checked/unchecked state of checkboxes

  const Memo({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.visibility = 'PRIVATE',
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
    tags,
    images,
    videos,
    audios,
    checklistStates,
  ];

  Memo copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? visibility,
    List<String>? tags,
    List<String>? images,
    List<String>? videos,
    List<String>? audios,
    Map<int, bool>? checklistStates,
  }) {
    return Memo(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      visibility: visibility ?? this.visibility,
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
      'tags': tags,
      'images': images,
      'videos': videos,
      'audios': audios,
      'checklistStates': serializedChecklistStates,
    };
  }

  factory Memo.fromJson(Map<String, dynamic> json) {
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

    return Memo(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isPinned: json['isPinned'] ?? false,
      visibility: json['visibility'] ?? 'PRIVATE',
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      audios: List<String>.from(json['audios'] ?? []),
      checklistStates: deserializedChecklistStates,
    );
  }
}
