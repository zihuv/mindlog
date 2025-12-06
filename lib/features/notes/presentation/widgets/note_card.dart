import 'package:flutter/material.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/presentation/widgets/image_display.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onEdit,
    this.onDelete,
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
                    _formatDateTime(note.createTime),
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
              const SizedBox(
                height: 2,
              ), // Minimal spacing between createTime and content
              // Note content as plain text
              Text(
                note.content,
                style: const TextStyle(fontSize: 14.0),
              ),
              // Display attached images as thumbnails if any
              if (note.images.isNotEmpty)
                Container(
                  height: 80, // Fixed height for image thumbnail container
                  margin: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: note.images.length > 3
                        ? 3
                        : note.images.length, // Show max 3 thumbnails
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        child: ImageDisplay(
                          imagePath: note.images[index],
                          thumbnailHeight: 80,
                          thumbnailWidth: 80,
                        ),
                      );
                    },
                  ),
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
