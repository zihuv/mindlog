import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/note_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../ui/design_system/design_system.dart';
import '../widgets/image_display.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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

  Future<void> _loadNoteForId(String noteId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<NoteController>();
      final note = await controller.getNoteById(noteId);

      if (note != null) {
        _contentController.text = note.content;

        // Convert image names to full paths
        _images = await _getImagePaths(noteId, note.images);
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

  Future<void> _loadNote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<NoteController>();
      final note = await controller.getNoteById(widget.noteId!);

      if (note != null) {
        _contentController.text = note.content;

        // Convert image names to full paths
        _images = await _getImagePaths(widget.noteId!, note.images);
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
    if (_contentController.text.trim().isEmpty && _images.isEmpty) {
      Get.showSnackbar(
        const GetSnackBar(
          message: 'Please enter some content or add an image',
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
          // If images were already added, create with all images
          _currentNoteId = await controller.createNoteWithImage(
            content: _contentController.text,
            imagePath: _images.first,
            notebookId: widget.notebookId,
          );
          _noteCreated = true; // Mark that note is now created

          // Add any additional images to the note
          for (int i = 1; i < _images.length; i++) {
            await controller.addImageToNote(
              noteId: _currentNoteId!,
              imagePath: _images[i],
              content: _contentController.text,
            );
          }
        } else {
          // If no images, create a regular note
          _currentNoteId = await controller.createNote(
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

        // Add any new images to the existing note
        // First, get the current note to check for existing images
        final currentNote = await controller.getNoteById(noteId);
        List<String> existingImageNames = currentNote?.images ?? [];

        // Add any new images that aren't already in the note
        for (final imagePath in _images) {
          String imageName = imagePath.split('/').last;
          if (!existingImageNames.contains(imageName)) {
            await controller.addImageToNote(
              noteId: noteId,
              imagePath: imagePath,
              content: _contentController.text,
            );
          }
        }

        // Reload the note to get the updated list of images only if it's not a new note
        if (!_isNewNote) {
          await _loadNote();
        } else if (_noteCreated && _currentNoteId != null) {
          // If it's a new note that has been created, load the created note
          await _loadNoteForId(_currentNoteId!);
        }
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
        // For both new and existing notes, just add the image to the local list
        _images.add(image.path);

        // If it's a new note that hasn't been created yet, save the image path for later
        if (_isNewNote && !_noteCreated) {
          // Just add the image to the pending list, don't create the note yet
          Get.showSnackbar(
            GetSnackBar(
              message: 'Image added. Save note to store image.',
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
            ),
          );
        } else {
          // If it's an existing note or a note that's already been created,
          // add the image to the existing note
          final controller = Get.find<NoteController>();
          await controller.addImageToNote(
            noteId: _currentNoteId ?? widget.noteId!,
            imagePath: image.path, // Add the new image to existing note
            content: _contentController.text,
          );

          // Reload the note to get the updated list of images
          if (!_isNewNote) {
            await _loadNote();
          } else if (_noteCreated && _currentNoteId != null) {
            // If it's a new note that has been created, load the created note
            await _loadNoteForId(_currentNoteId!);
          }

          Get.showSnackbar(
            const GetSnackBar(
              message: 'Image added to note successfully',
              duration: Duration(seconds: 2),
              snackPosition: SnackPosition.BOTTOM,
            ),
          );
        }
      } on Exception catch (e) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Error adding image: $e',
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
          ),
        );
      } catch (e) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Unexpected error adding image: $e',
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

  // Convert image names to full file paths
  Future<List<String>> _getImagePaths(String noteId, List<String> imageNames) async {
    final paths = <String>[];
    for (final imageName in imageNames) {
      try {
        // According to MediaService implementation, images are stored in {appDir}/images/{noteId}/{imageName}
        final appDir = await getApplicationDocumentsDirectory();
        String imagePath = path.join(appDir.path, 'images', noteId, imageName);
        paths.add(imagePath);
      } catch (e) {
        // If we can't get the path, return the original path as fallback
        paths.add(imageName);
      }
    }
    return paths;
  }

  Future<bool> _isFileAccessible(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  void _showFullscreenImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Image View'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          body: InteractiveViewer(
            minScale: 0.1,
            maxScale: 5.0,
            child: Container(
              constraints: const BoxConstraints.expand(),
              child: FutureBuilder<bool>(
                future: _isFileAccessible(imagePath),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                    );
                  } else {
                    return const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 50,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagesGrid() {
    // Show up to 9 images in a grid (3x3 max)
    final imagesToShow = _images.length > 9 ? _images.take(9).toList() : _images;

    // Calculate how many columns based on number of images
    int crossAxisCount;
    if (imagesToShow.length == 1) {
      crossAxisCount = 1; // Single image full width
    } else if (imagesToShow.length <= 4) {
      crossAxisCount = 2; // 2x2 grid for up to 4 images
    } else {
      crossAxisCount = 3; // 3x3 grid for more than 4 images
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling in the grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0, // Square aspect ratio
      ),
      itemCount: imagesToShow.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Show image in fullscreen when tapped
            _showFullscreenImage(context, imagesToShow[index]);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: FutureBuilder<bool>(
                future: _isFileAccessible(imagesToShow[index]),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Image.file(
                      File(imagesToShow[index]),
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Container(
                      color: Theme.of(context).dividerColor,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
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
                  // Display attached images in a grid (up to 9 images)
                  if (_images.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildImagesGrid(),
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
