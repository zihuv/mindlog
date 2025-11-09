import 'package:flutter/material.dart';

class JournalEntryScreen extends StatefulWidget {
  final Function(String content, String mood, DateTime entryDate) onSave;
  final String? initialContent;
  final String? initialMood;
  final DateTime?
  initialDate; // Added to allow specifying the date for the entry
  final bool isEdit; // Flag to indicate if this is an edit operation

  const JournalEntryScreen({
    Key? key,
    required this.onSave,
    this.initialContent,
    this.initialMood,
    this.initialDate, // Added parameter for initial date
    this.isEdit = false, // Default to false for new entries
  }) : super(key: key);

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late TextEditingController _contentController;
  late String _selectedMood;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.initialContent ?? '',
    );
    _selectedMood = widget.initialMood ?? 'content';
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialContent != null ? '编辑日记' : '新建日记'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Save the journal entry
                if (_contentController.text.isNotEmpty) {
                  DateTime entryDate;

                  // For both new entries and edits, use the initialDate from the calendar if provided
                  // If no initialDate is provided, use current date/time for new entries
                  if (widget.isEdit) {
                    // For edits, preserve the original date/time but allow time to be updated if needed
                    entryDate = widget.initialDate ?? DateTime.now();
                  } else {
                    // For new entries, use the initialDate (selected date from calendar) with 00:00 time for non-today dates
                    DateTime now = DateTime.now();
                    DateTime today = DateTime(now.year, now.month, now.day);
                    if (widget.initialDate != null) {
                      DateTime selectedDate = DateTime(widget.initialDate!.year, widget.initialDate!.month, widget.initialDate!.day);
                      // If selected date is today, use current time; otherwise use 00:00
                      if (selectedDate.isAtSameMomentAs(today)) {
                        // For today's entries, use current time
                        entryDate = DateTime(
                          widget.initialDate!.year,
                          widget.initialDate!.month,
                          widget.initialDate!.day,
                          now.hour,
                          now.minute,
                          now.second,
                        );
                      } else {
                        // For non-today entries, use 00:00
                        entryDate = DateTime(
                          widget.initialDate!.year,
                          widget.initialDate!.month,
                          widget.initialDate!.day,
                          0,
                          0,
                          0,
                        );
                      }
                    } else {
                      // Fallback to current date/time
                      entryDate = now;
                    }
                  }

                  widget.onSave(
                    _contentController.text,
                    _selectedMood,
                    entryDate,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor, // Use theme primary color
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('保存'),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // Dismiss the screen with a downward swipe
          if (details.velocity.pixelsPerSecond.dy > 500) {
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('心情如何？'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildMoodOption('happy', '😊'),
                  _buildMoodOption('content', '😌'),
                  _buildMoodOption('grateful', '🙏'),
                  _buildMoodOption('sad', '😔'),
                  _buildMoodOption('anxious', '😰'),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '写下你的想法...',
                  hintText: 'What\'s on your mind?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodOption(String mood, String emoji) {
    return ChoiceChip(
      label: Text(emoji),
      selected: _selectedMood == mood,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedMood = mood;
          });
        }
      },
    );
  }
}
