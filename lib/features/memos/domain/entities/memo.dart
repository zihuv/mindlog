import 'package:equatable/equatable.dart';

class Memo extends Equatable {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final String? visibility; // 'PUBLIC', 'PRIVATE', 'LIMITED'
  final List<String> tags;

  const Memo({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.visibility = 'PRIVATE',
    this.tags = const [],
  });

  @override
  List<Object?> get props => [id, content, createdAt, updatedAt, isPinned, visibility, tags];

  Memo copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? visibility,
    List<String>? tags,
  }) {
    return Memo(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      visibility: visibility ?? this.visibility,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPinned': isPinned,
      'visibility': visibility,
      'tags': tags,
    };
  }

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isPinned: json['isPinned'] ?? false,
      visibility: json['visibility'] ?? 'PRIVATE',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}