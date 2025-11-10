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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Memo' : 'New Memo'),
        actions: [
          TextButton(
            onPressed: _saveMemo,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Divider(),
            const SizedBox(height: 16),
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
                    decoration: const InputDecoration(
                      labelText: 'Visibility',
                    ),
                    items: ['PRIVATE', 'PUBLIC', 'LIMITED']
                        .map((String value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
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
      // Update existing memo
      memo = widget.initialMemo!.copyWith(
        content: _controller.text.trim(),
        updatedAt: DateTime.now(),
        isPinned: _isPinned,
        visibility: _visibility,
        tags: tags,
      );
    } else {
      // Create new memo
      memo = Memo(
        id: DateTime.now().millisecondsSinceEpoch,
        content: _controller.text.trim(),
        createdAt: DateTime.now(),
        isPinned: _isPinned,
        visibility: _visibility,
        tags: tags,
      );
    }

    // Save to storage
    await MemoService.instance.saveMemo(memo);

    // Call the onSave callback if provided
    widget.onSave?.call(memo);

    // Navigate back
    Navigator.pop(context);
  }
}