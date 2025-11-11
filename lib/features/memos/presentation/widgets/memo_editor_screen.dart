import 'package:flutter/material.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:mindlog/features/memos/memo_service.dart';

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
  final TextEditingController _tagsController = TextEditingController();
  bool _isPinned = false;
  String _visibility = 'PRIVATE';

  @override
  void initState() {
    super.initState();

    if (widget.initialMemo != null) {
      _controller.text = widget.initialMemo!.content;
      _isPinned = widget.initialMemo!.isPinned;
      _visibility = widget.initialMemo!.visibility ?? 'PRIVATE';

      // Format tags as comma-separated string
      if (widget.initialMemo!.tags.isNotEmpty) {
        _tagsController.text = widget.initialMemo!.tags.join(', ');
      }
    }
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

  void _insertHeading() {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = StringBuffer()
      ..write(text.substring(0, selection.start))
      ..write('## ')
      ..write(text.substring(selection.end));

    _controller.value = TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(
        offset: selection.start + 3,
      ), // 3 = length of "## "
    );
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
            // Markdown toolbar
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_box_outlined),
                    tooltip: 'Add task list item',
                    onPressed: _insertTaskList,
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted),
                    tooltip: 'Add bullet list',
                    onPressed: _insertBulletList,
                  ),
                  IconButton(
                    icon: const Icon(Icons.title),
                    tooltip: 'Add heading',
                    onPressed: _insertHeading,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText:
                      'What\'s on your mind?\n\nUse [ ] for unchecked items\nUse [x] for checked items',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const Divider(),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: 'work, personal, todo',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Pinned'),
                    value: _isPinned,
                    onChanged: (value) {
                      setState(() {
                        _isPinned = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _visibility,
                    decoration: const InputDecoration(labelText: 'Visibility'),
                    items: ['PRIVATE', 'PUBLIC', 'LIMITED']
                        .map(
                          (String value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _visibility = newValue ?? 'PRIVATE';
                      });
                    },
                  ),
                ),
              ],
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

    // Parse tags from comma-separated string
    List<String> tags = [];
    if (_tagsController.text.trim().isNotEmpty) {
      tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    Memo memo;
    if (widget.isEdit && widget.initialMemo != null) {
      // For edited memos, preserve the existing checklist states
      memo = widget.initialMemo!.copyWith(
        content: _controller.text.trim(),
        updatedAt: DateTime.now(),
        isPinned: _isPinned,
        visibility: _visibility,
        tags: tags,
        // Preserve existing checklist states
        // We'll extract them from the content if needed
      );
    } else {
      // For new memos, initialize with empty checklist states
      memo = Memo(
        id: DateTime.now().millisecondsSinceEpoch,
        content: _controller.text.trim(),
        createdAt: DateTime.now(),
        isPinned: _isPinned,
        visibility: _visibility,
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
