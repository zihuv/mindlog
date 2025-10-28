import 'package:flutter/material.dart';

class JournalEntryScreen extends StatefulWidget {
  final Function(String content, String mood, DateTime entryDate) onSave;
  final String? initialContent;
  final String? initialMood;
  final DateTime? initialDate; // Added to allow specifying the date for the entry

  const JournalEntryScreen({
    Key? key, 
    required this.onSave,
    this.initialContent,
    this.initialMood,
    this.initialDate, // Added parameter for initial date
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
    _contentController = TextEditingController(text: widget.initialContent ?? '');
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
                  // Use initialDate if provided, otherwise use current date
                  DateTime entryDate = widget.initialDate ?? DateTime.now();
                  widget.onSave(_contentController.text, _selectedMood, entryDate);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor, // Use theme primary color
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('保存'),
            ),
          ),
        ],
      ),
      body: Padding(
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