import 'package:equatable/equatable.dart';

enum NotebookType { standard, checklist, timer }

class Notebook extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final NotebookType type;
  final DateTime createTime;
  final DateTime? updateTime;

  const Notebook({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    this.type = NotebookType.standard,
    required this.createTime,
    this.updateTime,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    coverImage,
    type,
    createTime,
    updateTime,
  ];

  Notebook copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    NotebookType? type,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return Notebook(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      type: type ?? this.type,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'type': type.toString().split('.').last, // Get just the enum value
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
    };
  }

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      coverImage: json['coverImage'],
      type: _getNotebookTypeFromString(json['type'] ?? 'standard'),
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
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