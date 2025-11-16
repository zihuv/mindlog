import 'package:flutter/material.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/data/note_service.dart';
import 'package:uuid/uuid.dart';

class NoteEditorScreen extends StatefulWidget {
  final Function(Note note)? onSave;
  final Note? initialNote;
  final bool isEdit;

  const NoteEditorScreen({
    super.key,
    this.onSave,
    this.initialNote,
    this.isEdit = false,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.initialNote != null) {
      _controller.text = widget.initialNote!.content;
      // For editing, place cursor at the end of the content
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    } else {
      // For new note, start with empty text and cursor at the beginning
      _controller.text = '';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: 0),
      );
    }

    // Request focus after the widget is built to ensure cursor position is maintained
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // Ensure cursor is positioned at the beginning for new notes
      if (widget.initialNote == null) {
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: 0),
        );
      }
    });
  }

  void _insertTaskList() {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = StringBuffer()
      ..write(text.substring(0, selection.start))
      ..write('- [ ] ')
      ..write(text.substring(selection.end));

    _controller.value = TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(
        offset: selection.start + 6,
      ), // 6 = length of "- [ ] "
    );
  }

  void _insertBulletList() {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = StringBuffer()
      ..write(text.substring(0, selection.start))
      ..write('- ')
      ..write(text.substring(selection.end));

    _controller.value = TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(
        offset: selection.start + 2,
      ), // 2 = length of "- "
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Note' : 'New Note'),
        actions: [TextButton(onPressed: _saveNote, child: const Text('Save'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Enter your note here...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16.0),
                ),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: 16),
            // Bottom toolbar with formatting options
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: _insertTaskList,
                    icon: const Icon(Icons.check_box_outlined, size: 18),
                    label: const Text('Task'),
                  ),
                  TextButton.icon(
                    onPressed: _insertBulletList,
                    icon: const Icon(Icons.format_list_bulleted, size: 18),
                    label: const Text('List'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() async {
    final contextLocal = context; // Capture context before any async calls

    if (_controller.text.trim().isEmpty) {
      // Show error message if content is empty
      ScaffoldMessenger.of(contextLocal).showSnackBar(
        const SnackBar(
          content: Text('Note content cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tags have been removed in this refactor, so use empty list
    final tags = <String>[];

    Note note;
    if (widget.isEdit && widget.initialNote != null) {
      // For edited notes, preserve the existing checklist states
      // but update the tags based on the new content
      note = widget.initialNote!.copyWith(
        content: _controller.text.trim(),
        updatedAt: DateTime.now(),
        tags: tags,
        // Preserve existing pinned status and other values
      );
    } else {
      // For new notes, initialize with empty checklist states
      final uuid = const Uuid();
      note = Note(
        id: uuid.v7(),
        content: _controller.text.trim(),
        createdAt: DateTime.now(),
        isPinned: false, // Default to not pinned
        visibility: 'PRIVATE', // Default to private
        tags: tags,
        checklistStates: _extractChecklistStates(_controller.text.trim()),
      );
    }

    // Save to storage
    await NoteService.instance.saveNote(note);

    // Call the onSave callback if provided
    widget.onSave?.call(note);

    // Navigate back
    Navigator.pop(contextLocal);
  }

  Map<int, bool> _extractChecklistStates(String content) {
    final lines = content.split('\n');
    final Map<int, bool> states = {};

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (RegExp(r'^\s*[\-\*]\s+\[([ xX])\]\s+.*').hasMatch(line)) {
        final match = RegExp(
          r'^(\s*[\-\*]\s+)\[([ xX])\](.*)$',
        ).firstMatch(line);
        if (match != null) {
          final isChecked = match.group(2)!.trim().toLowerCase() == 'x';
          states[i] = isChecked;
        }
      }
    }

    return states;
  }
}
