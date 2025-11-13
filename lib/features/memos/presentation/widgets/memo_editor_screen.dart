import 'package:flutter/material.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:mindlog/features/memos/memo_service.dart';
import 'package:mindlog/core/utils/tag_parser.dart';

class MemoEditorScreen extends StatefulWidget {
  final Function(Memo memo)? onSave;
  final Memo? initialMemo;
  final bool isEdit;

  const MemoEditorScreen({
    Key? key,
    this.onSave,
    this.initialMemo,
    this.isEdit = false,
  }) : super(key: key);

  @override
  State<MemoEditorScreen> createState() => _MemoEditorScreenState();
}

class _MemoEditorScreenState extends State<MemoEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.initialMemo != null) {
      _controller.text = widget.initialMemo!.content;
      // For editing, place cursor at the end of the content
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    } else {
      // For new memo, start with empty text and cursor at the beginning
      _controller.text = '';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: 0),
      );
    }

    // Request focus after the widget is built to ensure cursor position is maintained
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // Ensure cursor is positioned at the beginning for new memos
      if (widget.initialMemo == null) {
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
        title: Text(widget.isEdit ? 'Edit Memo' : 'New Memo'),
        actions: [TextButton(onPressed: _saveMemo, child: const Text('Save'))],
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
                  hintText: 'Enter your memo here...',
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

  void _saveMemo() async {
    if (_controller.text.trim().isEmpty) {
      // Show error message if content is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memo content cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Extract tags from the content
    final tags = TagParser.extractTags(_controller.text.trim());

    Memo memo;
    if (widget.isEdit && widget.initialMemo != null) {
      // For edited memos, preserve the existing checklist states
      // but update the tags based on the new content
      memo = widget.initialMemo!.copyWith(
        content: _controller.text.trim(),
        updatedAt: DateTime.now(),
        tags: tags,
        // Preserve existing pinned status and other values
      );
    } else {
      // For new memos, initialize with empty checklist states
      memo = Memo(
        id: DateTime.now().millisecondsSinceEpoch,
        content: _controller.text.trim(),
        createdAt: DateTime.now(),
        isPinned: false, // Default to not pinned
        visibility: 'PRIVATE', // Default to private
        tags: tags,
        checklistStates: _extractChecklistStates(_controller.text.trim()),
      );
    }

    // Save to storage
    await MemoService.instance.saveMemo(memo);

    // Call the onSave callback if provided
    widget.onSave?.call(memo);

    // Navigate back
    Navigator.pop(context);
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
