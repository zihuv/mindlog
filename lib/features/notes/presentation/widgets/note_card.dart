import 'package:flutter/material.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/presentation/components/components/markdown_checklist.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(Note)? onChecklistChanged;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onChecklistChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        // Using InkWell to make the entire card tappable
        onTap: onEdit, // Tap anywhere on the card to edit
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateTime(note.updatedAt ?? note.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                        onSelected: (String result) {
                          if (result == 'edit') {
                            onEdit?.call();
                          } else if (result == 'delete') {
                            onDelete?.call();
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 2), // Minimal spacing between time and content
              // Note content with markdown support for checkboxes (interactive)
              MarkdownChecklist(
                text: note.content,
                style: const TextStyle(fontSize: 14.0),
                onTextChange: (updatedText) async {
                  // Create an updated note with the new content
                  final updatedNote = note.copyWith(
                    content: updatedText,
                  );

                  // Call the parent callback to update the note
                  onChecklistChanged?.call(updatedNote);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date';
    }
    return dateTime.toString().split(
      '.',
    )[0]; // Formats as 'YYYY-MM-DD HH:MM:SS'
  }
}
