import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import 'package:image_picker/image_picker.dart';

class NoteDetailScreen extends StatefulWidget {
  final int? noteId;

  const NoteDetailScreen({Key? key, this.noteId}) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  late bool _isNewNote;
  List<String> _tags = [];
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
        _tags = List.from(note.tags); // Create a copy to avoid potential mutations
        _checklistStates = Map.from(note.checklistStates);
        _updateTagsController();
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Error loading note: $e',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateTagsController() {
    _tagsController.text = _tags.join(',');
  }

  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty) {
      Get.showSnackbar(const GetSnackBar(
        message: 'Please enter some content',
        duration: Duration(seconds: 2),
      ));
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
          tags: _tags.isEmpty ? [] : _tags,
          checklistStates: _checklistStates,
        );
      } else {
        await controller.updateNote(
          id: widget.noteId!,
          content: _contentController.text,
          tags: _tags.isEmpty ? [] : _tags,
          checklistStates: _checklistStates,
        );
      }

      if (mounted) {
        Get.back(result: true); // Indicate success
      }
    } on Exception catch (e) {
      if (mounted) {
        Get.showSnackbar(GetSnackBar(
          message: 'Error saving note: $e',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        ));
      }
    } catch (e) {
      if (mounted) {
        Get.showSnackbar(GetSnackBar(
          message: 'Unexpected error saving note: $e',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        ));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTag() async {
    if (_tagsController.text.trim().isNotEmpty) {
      final newTags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      setState(() {
        _tags = newTags;
      });
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // In a real app, you would save the image to the note's media directory
      // and update the note with the image reference
      // For now, showing a simple message
      Get.showSnackbar(const GetSnackBar(
        message: 'Image selected. In a full implementation, it would be saved with the note.',
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewNote ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Note Content',
                        border: OutlineInputBorder(),
                        hintText: 'Write your note here...',
                      ),
                      minLines: 3,
                      maxLines: 10, // Set a maximum number of lines to prevent infinite height
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags (comma-separated)',
                            border: OutlineInputBorder(),
                            hintText: 'work, personal, important...',
                          ),
                          onEditingComplete: _addTag,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addTag,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 4.0,
                      children: _tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                onDeleted: () {
                                  setState(() {
                                    _tags.remove(tag);
                                    _updateTagsController();
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                  ),
                  // Additional media buttons could be added here
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}