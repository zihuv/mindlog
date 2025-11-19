import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String content;
  final DateTime createTime;
  final DateTime? updateTime;
  final String? notebookId; // Foreign key to notebook
  final List<String> images;
  final List<String> videos;
  final List<String> audios;

  const Note({
    required this.id,
    required this.content,
    required this.createTime,
    this.updateTime,
    this.notebookId,
    this.images = const [],
    this.videos = const [],
    this.audios = const [],
  });

  @override
  List<Object?> get props => [
    id,
    content,
    createTime,
    updateTime,
    notebookId,
    images,
    videos,
    audios,
  ];

  Note copyWith({
    String? id,
    String? content,
    DateTime? createTime,
    DateTime? updateTime,
    String? notebookId,
    List<String>? images,
    List<String>? videos,
    List<String>? audios,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
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
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
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
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
      notebookId: json['notebookId'],
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      audios: List<String>.from(json['audios'] ?? []),
    );
  }
}
