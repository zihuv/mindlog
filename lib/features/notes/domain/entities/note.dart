import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notebookId; // Foreign key to notebook
  final List<String> images;
  final List<String> videos;
  final List<String> audios;

  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.notebookId,
    this.images = const [],
    this.videos = const [],
    this.audios = const [],
  });

  @override
  List<Object?> get props => [
    id,
    content,
    createdAt,
    updatedAt,
    notebookId,
    images,
    videos,
    audios,
  ];

  Note copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notebookId,
    List<String>? images,
    List<String>? videos,
    List<String>? audios,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notebookId: notebookId ?? this.notebookId,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      audios: audios ?? this.audios,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notebookId': notebookId,
      'images': images,
      'videos': videos,
      'audios': audios,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      notebookId: json['notebookId'],
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      audios: List<String>.from(json['audios'] ?? []),
    );
  }
}
