import 'package:equatable/equatable.dart';

class JournalEntry extends Equatable {
  final int id;
  final String content;
  final DateTime dateTime;
  final String mood;

  JournalEntry({
    required this.id,
    required this.content,
    required this.dateTime,
    required this.mood,
  });

  @override
  List<Object> get props => [id, content, dateTime, mood];
}
