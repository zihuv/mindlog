import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindlog/ui/design_system/design_system.dart';
import 'package:mindlog/utils/media_util.dart';
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
  bool _selectingImages = false;
  final Set<int> _selectedImageIndices = <int>{};

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading note: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading note: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting note: $e'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty && _images.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter some content or add an image'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
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
          // Process images and add them to the note
          for (int i = 0; i < _images.length; i++) {
            final imagePath = _images[i];
            final imageFile = File(imagePath);
            if (await imageFile.exists()) {
              // Use compressAndSaveImage to handle both compression and saving
              final savedImagePath =
                  await MediaUtil.compressAndSaveImage(
                    '', // Will be set when note is created
                    imageFile,
                    null,
                  );

              final savedImageFile = File(savedImagePath);

              // On first image, create the note, on subsequent images add them
              if (i == 0) {
                _currentNoteId = await controller.createNoteWithImage(
                  content: _contentController.text,
                  imagePath: savedImageFile.path,
                  notebookId: widget.notebookId,
                );
                _noteCreated = true; // Mark that note is now created
              } else {
                // Add additional images to the newly created note
                await controller.addImageToNote(
                  noteId: _currentNoteId!,
                  imagePath: savedImageFile.path,
                  content: _contentController.text,
                );
              }
            }
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note ID is not available'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });
          return;
        }

        // First, get the current note to check for existing images
        final currentNote = await controller.getNoteById(noteId);
        List<String> existingImageNames = currentNote?.images ?? [];

        // Determine which images are new and need to be added
        List<String> newImagePaths = [];
        for (final imagePath in _images) {
          String imageName = imagePath.split('/').last;
          if (!existingImageNames.contains(imageName)) {
            newImagePaths.add(imagePath);
          }
        }

        // Update the note content first
        await controller.updateNote(
          id: noteId,
          content: _contentController.text,
          notebookId: widget.notebookId,
        );

        // Add and process new images individually
        for (final imagePath in newImagePaths) {
          final imageFile = File(imagePath);
          if (await imageFile.exists()) {
            // Use compressAndSaveImage to handle both compression and saving
            final savedImagePath =
                await MediaUtil.compressAndSaveImage(
                  noteId,
                  imageFile,
                  null,
                );

            final savedImageFile = File(savedImagePath);

            // Add the processed image to the note
            await controller.addImageToNote(
              noteId: noteId,
              imagePath: savedImageFile.path,
              content: _contentController.text,
            );
          }
        }
      }

      // Final check to make sure the note data is updated
      if (_isNewNote && _currentNoteId != null && !_noteCreated) {
        await _loadNoteForId(_currentNoteId!);
      } else if (!_isNewNote) {
        await _loadNote();
      }

      // Only navigate back if the widget is still mounted
      // Check mounted before navigating back to prevent errors
      if (mounted) {
        Get.back(result: true); // Indicate success
      }
    } on Exception catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving note: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unexpected error saving note: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
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
        // Verify that the image file is accessible before adding it
        final file = File(image.path);
        if (await file.exists()) {
          // For both new and existing notes, just add the image to the local list
          // Don't add image to the note yet - only compress and add during save
          _images.add(image.path);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Could not access the selected image. Please try again.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });
        }
      } on Exception catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error selecting image: $e'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unexpected error selecting image: $e'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
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
  Future<List<String>> _getImagePaths(
    String noteId,
    List<String> imageNames,
  ) async {
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
                    return Image.file(File(imagePath), fit: BoxFit.contain);
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

  Future<void> _deleteSelectedImages() async {
    if (_selectedImageIndices.isEmpty) return;

    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Images'),
          content: Text(
            'Are you sure you want to delete ${_selectedImageIndices.length} image(s)?',
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

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<NoteController>();
      String? noteId = widget.noteId ?? _currentNoteId;

      if (noteId != null) {
        // Get the note to retrieve the list of image names
        final note = await controller.getNoteById(noteId);
        List<String> currentImageNames = note?.images ?? [];

        // Determine which image names to delete
        List<String> imagesToDelete = [];
        for (int index in _selectedImageIndices) {
          if (index < _images.length) {
            String imagePath = _images[index];
            String imageName = imagePath.split('/').last;
            imagesToDelete.add(imageName);
          }
        }

        // Remove the selected images from the current list
        List<String> updatedImageNames = List.from(currentImageNames);
        for (String imageName in imagesToDelete) {
          updatedImageNames.remove(imageName);
        }

        // Update note media (passing the same content to update images)
        await controller.updateNoteMedia(
          noteId: noteId,
          imageNames: updatedImageNames,
          noteContent: _contentController.text,
          notebookId: widget.notebookId,
        );

        // Update the local list of images based on updated image names
        _images = await _getImagePaths(noteId, updatedImageNames);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Images deleted successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting images: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndDeleteSingleImage(int index) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
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

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? noteId = widget.noteId ?? _currentNoteId;

      if (noteId != null && index < _images.length) {
        // Get the note to retrieve the list of image names
        final note = await Get.find<NoteController>().getNoteById(noteId);
        List<String> currentImageNames = note?.images ?? [];

        // Get the name of the image to delete
        String imagePath = _images[index];
        String imageName = imagePath.split('/').last;

        // Remove the image name from the current list
        List<String> updatedImageNames = List.from(currentImageNames)
          ..remove(imageName);

        // Update note media (passing the same content to update images)
        final controller = Get.find<NoteController>();
        await controller.updateNoteMedia(
          noteId: noteId,
          imageNames: updatedImageNames,
          noteContent: _contentController.text,
          notebookId: widget.notebookId,
        );

        // Update the local list of images based on updated image names
        _images = await _getImagePaths(noteId, updatedImageNames);
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting image: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImagesGrid() {
    // Show up to 9 images in a grid with consistent 3x3 layout
    final imagesToShow = _images.length > 9
        ? _images.take(9).toList()
        : _images;

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero, // Remove default padding
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling in the grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Always use 3 columns for consistent layout
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0, // Square aspect ratio
      ),
      itemCount: imagesToShow.length,
      itemBuilder: (context, index) {
        bool isSelected = _selectedImageIndices.contains(index);
        return GestureDetector(
          onTap: () {
            // Show image in fullscreen when tapped
            if (_selectingImages) {
              setState(() {
                if (_selectedImageIndices.contains(index)) {
                  _selectedImageIndices.remove(index);
                } else {
                  _selectedImageIndices.add(index);
                }
              });
            } else {
              _showFullscreenImage(context, imagesToShow[index]);
            }
          },
          onLongPress: () {
            if (!_selectingImages && !_isNewNote) {
              setState(() {
                _selectingImages = true;
                _selectedImageIndices.add(index);
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: isSelected ? 2.0 : 0.5,
              ),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand, // Make stack fill the container
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: FutureBuilder<bool>(
                    future: _isFileAccessible(imagesToShow[index]),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return Image.file(
                          File(imagesToShow[index]),
                          fit: BoxFit.cover, // Make image fill the container
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
                // Always show delete button for individual image deletion
                if (!_selectingImages)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () {
                        // Directly delete this image
                        _confirmAndDeleteSingleImage(index);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                // Show selection indicator when in selection mode
                if (_selectingImages)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, size: 16, color: Colors.white),
                    ),
                  ),
              ],
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
        title: Text(
          _isNewNote
              ? 'New Note'
              : _selectingImages
              ? 'Select Images to Delete'
              : 'Edit Note',
        ),
        actions: [
          if (_selectingImages)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _selectedImageIndices.isEmpty
                  ? null
                  : () {
                      _deleteSelectedImages();
                      setState(() {
                        _selectingImages = false;
                        _selectedImageIndices.clear();
                      });
                    },
            ),
          if (_selectingImages)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _selectingImages = false;
                  _selectedImageIndices.clear();
                });
              },
            ),
          if (!_selectingImages && !_isNewNote)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteNote,
            ),
          if (!_selectingImages)
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
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
                          8, // Set a reasonable maximum to allow scrolling
                      keyboardType: TextInputType.multiline,
                    ),
                    const Gap(16.0),
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
                  ],
                ),
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
