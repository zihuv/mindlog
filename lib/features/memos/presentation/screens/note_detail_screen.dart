import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/note_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../ui/design_system/design_system.dart';
import '../components/components/markdown_checklist.dart';

class NoteDetailScreen extends StatefulWidget {
  final String? noteId;
  final String? notebookId;

  const NoteDetailScreen({Key? key, this.noteId, this.notebookId}) : super(key: key);

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
                      maxLines:
                          10, // Set a maximum number of lines to prevent infinite height
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  SizedBox(height: AppPadding.large.top),

                  SizedBox(height: AppPadding.large.top),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                  ),
                  // Preview of the note content with markdown checklist rendering
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8.0),
                        MarkdownChecklist(
                          text: _contentController.text,
                          style: TextStyle(
                            fontSize: AppFontSize.body,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onTextChange: (updatedText) {
                            _contentController.text = updatedText;
                            // Update checklist states based on the new content
                            _updateChecklistStates(updatedText);
                          },
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

  // Update checklist states based on the content
  void _updateChecklistStates(String content) {
    List<String> lines = content.split('\n');
    Map<int, bool> newChecklistStates = {};

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.startsWith('- [') && line.contains('] ')) {
        // Extract checkbox state
        bool isChecked = line.substring(3, 4) == 'x';
        String taskContent = line.substring(6); // Skip "- [x] " or "- [ ] "

        // Create a unique key for this checklist item based on content and position
        int key = taskContent.hashCode + i;
        newChecklistStates[key] = isChecked;
      }
    }

    setState(() {
      _checklistStates = newChecklistStates;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
