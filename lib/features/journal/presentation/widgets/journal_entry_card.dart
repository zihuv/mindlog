import 'package:flutter/material.dart';
import '../../domain/entities/journal_entry.dart';

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const JournalEntryCard({Key? key, required this.entry, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column on the left (updated to accommodate full date-time format)
            SizedBox(
              width: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.dateTime.year}-${entry.dateTime.month.toString().padLeft(2, '0')}-${entry.dateTime.day.toString().padLeft(2, '0')} ${entry.dateTime.hour.toString().padLeft(2, '0')}:${entry.dateTime.minute.toString().padLeft(2, '0')}:${entry.dateTime.second.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CircleAvatar(
                    backgroundColor: _getMoodColor(entry.mood),
                    radius: 6,
                    child: Text(
                      _getMoodEmoji(entry.mood),
                      style: const TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content column on the right
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.content,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'happy':
        return Colors.yellow[600]!;
      case 'content':
        return Colors.green[600]!;
      case 'grateful':
        return Colors.purple[600]!;
      case 'sad':
        return Colors.blue[600]!;
      case 'anxious':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'happy':
        return '😊';
      case 'content':
        return '😌';
      case 'grateful':
        return '🙏';
      case 'sad':
        return '😔';
      case 'anxious':
        return '😰';
      default:
        return '😐';
    }
  }
}
