import 'package:flutter/material.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:mindlog/features/memos/presentation/components/components/markdown_checklist.dart';

class MemoCard extends StatelessWidget {
  final Memo memo;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(Memo)? onChecklistChanged;

  const MemoCard({
    super.key,
    required this.memo,
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
                    _formatDateTime(memo.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      if (memo.isPinned)
                        Icon(Icons.push_pin, size: 16, color: Colors.grey),
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
              // Memo content with markdown support for checkboxes (interactive)
              MarkdownChecklist(
                text: memo.content,
                style: const TextStyle(fontSize: 14.0),
                onTextChange: (updatedText) async {
                  // Create an updated memo with the new content
                  final updatedMemo = memo.copyWith(
                    content: updatedText,
                  );

                  // Call the parent callback to update the memo
                  onChecklistChanged?.call(updatedMemo);
                },
              ),
              if (memo.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4.0,
                  children: memo.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return dateTime.toString().split(
      '.',
    )[0]; // Formats as 'YYYY-MM-DD HH:MM:SS'
  }
}
