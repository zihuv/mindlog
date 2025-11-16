import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/note_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../ui/design_system/design_system.dart';

class NoteDetailScreen extends StatefulWidget {
  final String? noteId;
  final String? notebookId;

  const NoteDetailScreen({super.key, this.noteId, this.notebookId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final TextEditingController _contentController = TextEditingController();
  late bool _isNewNote;
  bool _isLoading = false;
  Map<int, bool> _checklistStates = {};

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.noteId == null;

    _contentController.addListener(_onContentChanged);

    if (!_isNewNote) {
      _loadNote();
    }
  }

  Future<void> _loadNote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<NoteController>();
      final note = await controller.getNoteById(widget.noteId!);

      if (note != null) {
        _contentController.text = note.content;
        _checklistStates = Map.from(note.checklistStates);
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Error loading note: $e',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote() async {
    // Show confirmation dialog before deleting
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final controller = Get.find<NoteController>();
        await controller.deleteNote(widget.noteId!);

        if (mounted) {
          Get.back(result: true); // Indicate success and navigate back
        }
      } catch (e) {
        if (mounted) {
          Get.showSnackbar(
            GetSnackBar(
              message: 'Error deleting note: $e',
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty) {
      Get.showSnackbar(
        const GetSnackBar(
          message: 'Please enter some content',
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<NoteController>();

      // Parse the content to update checklist states before saving
      _updateChecklistStatesFromContent();

      if (_isNewNote) {
        await controller.createNote(
          content: _contentController.text,
          checklistStates: _checklistStates,
          notebookId: widget.notebookId, // Associate note with notebook if provided
        );
      } else {
        await controller.updateNote(
          id: widget.noteId!,
          content: _contentController.text,
          checklistStates: _checklistStates,
          notebookId: widget.notebookId, // Update notebook association if needed
        );
      }

      if (mounted) {
        Get.back(result: true); // Indicate success
      }
    } on Exception catch (e) {
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Error saving note: $e',
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Unexpected error saving note: $e',
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      // In a real app, you would save the image to the note's media directory
      // and update the note with the image reference
      // For now, showing a simple message
      Get.showSnackbar(
        const GetSnackBar(
          message:
              'Image selected. In a full implementation, it would be saved with the note.',
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _insertChecklist() {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final start = selection.start.clamp(0, text.length);
    final end = selection.end.clamp(0, text.length);

    final newText = StringBuffer()
      ..write(text.substring(0, start))
      ..write('- [ ] ')
      ..write(text.substring(end));

    _contentController.value = TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(
        offset: start + 6, // 6 = length of "- [ ] "
      ),
    );
  }

  void _insertBulletList() {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final start = selection.start.clamp(0, text.length);
    final end = selection.end.clamp(0, text.length);

    final newText = StringBuffer()
      ..write(text.substring(0, start))
      ..write('- ')
      ..write(text.substring(end));

    _contentController.value = TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(
        offset: start + 2, // 2 = length of "- "
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewNote ? 'New Note' : 'Edit Note'),
        actions: [
          if (!_isNewNote) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteNote,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: AppPadding.large,
              child: Column(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Note Content',
                        border: OutlineInputBorder(
                          borderRadius: AppBorderRadius.inputField,
                        ),
                        hintText: 'Write your note here...',
                      ),
                      minLines: 3,
                      maxLines: 10, // Set a maximum number of lines to prevent infinite height
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Toolbar for formatting options
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image),
                          tooltip: 'Add Image',
                          onPressed: _pickImage,
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_box_outlined),
                          tooltip: 'Insert Checklist',
                          onPressed: _insertChecklist,
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_list_bulleted),
                          tooltip: 'Insert Unordered List',
                          onPressed: _insertBulletList,
                        ),
                      ],
                    ),
                  ),
                  // Additional media buttons could be added here
                ],
              ),
            ),
    );
  }


  // Parse the content to update checklist states based on - [ ] and - [x] patterns
  void _onContentChanged() {
    // Update checklist states whenever the content changes
    _updateChecklistStatesFromContent();
  }

  void _updateChecklistStatesFromContent() {
    List<String> lines = _contentController.text.split('\n');
    Map<int, bool> newChecklistStates = {};

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      // Check for checklist format: "- [x] task" or "- [ ] task" (with optional indentation)
      final checklistRegex = RegExp(r'^(\s*)[-*]\s+\[([ xX])\]\s+(.+)$');
      final match = checklistRegex.firstMatch(line);

      if (match != null) {
        // Extract checkbox state
        bool isChecked = match.group(2)!.trim().toLowerCase() == 'x';
        String taskContent = match.group(3)!.trim(); // Get the task content after the checkbox

        // Create a unique key for this checklist item based on content and position
        int key = _generateChecklistKey(taskContent, i);
        newChecklistStates[key] = isChecked;
      }
    }

    _checklistStates = newChecklistStates;
  }

  // Helper function to generate consistent keys (same as in controller)
  int _generateChecklistKey(String content, int position) {
    return content.hashCode + position;
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _contentController.dispose();
    super.dispose();
  }
}
