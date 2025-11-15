import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:mindlog/features/memos/presentation/screens/note_detail_screen.dart';
import 'package:mindlog/ui/design_system/design_system.dart';
import 'dart:io';

class NotebookDetailScreen extends StatefulWidget {
  final String? notebookId;
  final Notebook? notebook; // Pass a new notebook object when creating

  const NotebookDetailScreen({Key? key, this.notebookId, this.notebook})
    : super(key: key);

  @override
  State<NotebookDetailScreen> createState() => _NotebookDetailScreenState();
}

class _NotebookDetailScreenState extends State<NotebookDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _coverImage;
  NotebookType _type = NotebookType.standard;
  late NotebookController _notebookController;
  late NoteController _noteController;
  bool _isLoading = false;

  bool get _isNewNotebook =>
      widget.notebookId == null || widget.notebookId!.isEmpty;

  @override
  void initState() {
    super.initState();
    _notebookController = Get.isRegistered<NotebookController>()
        ? Get.find<NotebookController>()
        : Get.put(NotebookController());
    _noteController = Get.isRegistered<NoteController>()
        ? Get.find<NoteController>()
        : Get.put(NoteController());

    if (!_isNewNotebook) {
      // Editing an existing notebook
      _loadNotebook();
    } else {
      // Creating a new notebook - set default values
      _titleController.text = '';
      _descriptionController.text = '';
      _coverImage = null;
      _type = NotebookType.standard;
    }
  }

  Future<void> _loadNotebook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notebook = await _notebookController.getNotebookById(
        widget.notebookId!,
      );
      if (notebook != null) {
        _titleController.text = notebook.title;
        _descriptionController.text = notebook.description ?? '';
        _coverImage = notebook.coverImage;
        _type = notebook.type;
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Error loading notebook: $e',
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


  Future<void> _saveNotebook() async {
    if (_titleController.text.trim().isEmpty) {
      Get.showSnackbar(
        const GetSnackBar(
          message: 'Please enter a title for the notebook',
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isNewNotebook) {
        // Create a new notebook
        await _notebookController.createNotebook(
          title: _titleController.text,
          description: _descriptionController.text,
          coverImage: _coverImage,
          type: _type,
        );
      } else {
        // Update an existing notebook
        await _notebookController.updateNotebook(
          id: widget.notebookId!,
          title: _titleController.text,
          description: _descriptionController.text,
          coverImage: _coverImage,
          type: _type,
        );
      }

      if (mounted) {
        Get.back(result: true); // Indicate success
      }
    } on Exception catch (e) {
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Error saving notebook: $e',
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Unexpected error saving notebook: $e',
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

  Future<void> _deleteNotebook() async {
    if (widget.notebookId == null) return;

    // Show confirmation dialog before deleting
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notebook'),
          content: const Text(
            'Are you sure you want to delete this notebook? All notes in this notebook will also be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              child: const Text('Delete'),
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
        await _notebookController.deleteNotebook(widget.notebookId!);

        if (mounted) {
          Get.back(
            result: true,
          ); // Indicate success and return to previous screen
        }
      } catch (e) {
        if (mounted) {
          Get.showSnackbar(
            GetSnackBar(
              message: 'Error deleting notebook: $e',
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

  Future<void> _pickCoverImage() async {
    final imagePath = await _notebookController.pickNotebookCoverImage();
    if (imagePath != null) {
      setState(() {
        _coverImage = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewNotebook ? 'New Notebook' : 'Edit Notebook'),
        actions: [
          // Show delete button only when editing an existing notebook
          if (!_isNewNotebook &&
              widget.notebookId != null &&
              widget.notebookId!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteNotebook,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNotebook,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: AppPadding.large,
              child: Column(
                children: [
                  // Cover image section
                  GestureDetector(
                    onTap: _pickCoverImage,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: AppBorderRadius.card,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                      ),
                      child: _coverImage != null
                          ? Image.file(
                              // This would be an actual file path in a real implementation
                              File(_coverImage!),
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.image_outlined,
                              size: 48.0,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Title input
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Notebook Title',
                      border: OutlineInputBorder(
                        borderRadius: AppBorderRadius.inputField,
                      ),
                      hintText: 'Enter notebook title...',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Type selection
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                      borderRadius: AppBorderRadius.inputField,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<NotebookType>(
                        isExpanded: true,
                        value: _type,
                        onChanged: (NotebookType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _type = newValue;
                            });
                          }
                        },
                        items: NotebookType.values.map((NotebookType type) {
                          return DropdownMenuItem<NotebookType>(
                            value: type,
                            child: Text(
                              type.toString().split('.').last,
                              style: TextStyle(fontSize: AppFontSize.body),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Description input
                  Expanded(
                    child: TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: AppBorderRadius.inputField,
                        ),
                        hintText: 'Enter notebook description...',
                      ),
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
    );
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
