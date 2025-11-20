import 'dart:io';
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
  List<String> _images = [];
  bool _noteCreated = false; // Track if a new note has been created
  String? _currentNoteId; // Store the current note ID after creation

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
        _images = [...note.images]; // Store the images
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
          content: const Text(
            'Are you sure you want to delete this note? This action cannot be undone.',
          ),
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

      if (_isNewNote && !_noteCreated) {
        // For a new note that hasn't been created yet
        if (_images.isNotEmpty) {
          // If images were already added, create with images
          await controller.createNoteWithImage(
            content: _contentController.text,
            imagePath: _images.first,
            notebookId: widget.notebookId,
          );
          _noteCreated = true; // Mark that note is now created
        } else {
          // If no images, create a regular note
          await controller.createNote(
            content: _contentController.text,
            notebookId: widget.notebookId,
          );
        }
      } else {
        // For existing notes or notes that have already been created
        String? noteId = widget.noteId ?? _currentNoteId;
        if (noteId == null) {
          Get.showSnackbar(
            const GetSnackBar(
              message: 'Note ID is not available',
              duration: Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
            ),
          );
          return;
        }

        await controller.updateNote(
          id: noteId,
          content: _contentController.text,
          notebookId: widget.notebookId,
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
    await _selectImage(ImageSource.gallery);
  }

  Future<void> _selectImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final controller = Get.find<NoteController>();

        if (_isNewNote) {
          // If it's a new note, we need to create it first with the content
          _currentNoteId = await controller.createNoteWithImage(
            content: _contentController.text,
            imagePath: image.path, // Add the selected image
            notebookId: widget.notebookId,
          );
          _noteCreated = true; // Mark that the note has been created

          // After creating the note, navigate back
          if (mounted) {
            Get.back(result: true);
          }
        } else {
          // If updating an existing note, add the image to existing note
          await controller.addImageToNote(
            noteId: widget.noteId!,
            imagePath: image.path, // Add the new image to existing note
            content: _contentController.text,
          );

          // Reload the note to refresh the UI
          await _loadNote();

          // Update the images list with the newly added image
          setState(() {
            _images.add(image.path);
          });
        }

        Get.showSnackbar(
          const GetSnackBar(
            message: 'Image added to note successfully',
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
          ),
        );
      } catch (e) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Error adding image: $e',
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
                      maxLines:
                          10, // Set a maximum number of lines to prevent infinite height
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Display attached images
                  if (_images.isNotEmpty)
                    Container(
                      height: 120, // Fixed height for image container
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 0.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(_images[index]),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
