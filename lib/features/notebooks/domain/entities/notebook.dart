import 'package:equatable/equatable.dart';

enum NotebookType { standard, checklist, timer }

class Notebook extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final NotebookType type;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Notebook({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    this.type = NotebookType.standard,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    coverImage,
    type,
    createdAt,
    updatedAt,
  ];

  Notebook copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    NotebookType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notebook(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'type': type.toString().split('.').last, // Get just the enum value
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      coverImage: json['coverImage'],
      type: _getNotebookTypeFromString(json['type'] ?? 'standard'),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  static NotebookType _getNotebookTypeFromString(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'checklist':
        return NotebookType.checklist;
      case 'timer':
        return NotebookType.timer;
      case 'standard':
      default:
        return NotebookType.standard;
    }
  }
}