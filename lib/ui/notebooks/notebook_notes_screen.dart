import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:mindlog/ui/design_system/design_system.dart';
import 'package:mindlog/features/notes/presentation/components/components/markdown_checklist.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class NotebookNotesScreen extends StatefulWidget {
  final String notebookId;

  const NotebookNotesScreen({super.key, required this.notebookId});

  @override
  State<NotebookNotesScreen> createState() => _NotebookNotesScreenState();
}

class _NotebookNotesScreenState extends State<NotebookNotesScreen> {
  late NotebookController _notebookController;
  late NoteController _noteController;
  List<Note> _notes = [];
  Notebook? _notebook;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notebookController = Get.isRegistered<NotebookController>()
        ? Get.find<NotebookController>()
        : Get.put(NotebookController());
    _noteController = Get.isRegistered<NoteController>()
        ? Get.find<NoteController>()
        : Get.put(NoteController());

    _loadNotebook();
    _loadNotes();
  }

  Future<void> _loadNotebook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notebook = await _notebookController.getNotebookById(
        widget.notebookId,
      );
      if (notebook != null) {
        _notebook = notebook;
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Error loading notebook info: $e',
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

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _notes = await _noteController.getNotesByNotebookId(widget.notebookId);
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Error loading notes: $e',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Remove the AppBar as requested
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Notebook title as a header with back button
                Container(
                  width: double.infinity,
                  padding: AppPadding.medium,
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    boxShadow: AppBoxShadow.appBar,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Get.back(); // Navigate back to previous screen
                        },
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _notebook?.title ?? 'Notes',
                          style: TextStyle(
                            fontSize: AppFontSize.large,
                            fontWeight: AppFontWeight.medium,
                            color: Theme.of(
                              context,
                            ).appBarTheme.titleTextStyle?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Notes list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _loadNotes();
                    },
                    child: _notes.isEmpty
                        ? const Center(
                            child: Text(
                              'No notes yet',
                              style: TextStyle(
                                fontSize: AppFontSize.body,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              final note = _notes[index];
                              return Card(
                                margin: AppPadding.small,
                                child: Stack(
                                  children: [
                                    // Full card tap gesture
                                    Positioned.fill(
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.to(
                                            () => NoteDetailScreen(noteId: note.id),
                                          )?.then((value) {
                                            if (value == true) {
                                              _loadNotes(); // Refresh the notes list after editing
                                            }
                                          });
                                        },
                                        // This allows the gesture detector to be behind other widgets
                                        behavior: HitTestBehavior.translucent,
                                      ),
                                    ),
                                    // Content and images
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Content area (always shown)
                                        Container(
                                          padding: AppPadding.medium,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                constraints: const BoxConstraints(
                                                  maxHeight: 60, // Limit height to 2 lines
                                                ),
                                                child: MarkdownChecklist(
                                                  text: note.content.length > 50
                                                      ? '${note.content.substring(0, 50)}...'
                                                      : note.content,
                                                  style: TextStyle(
                                                    fontSize: AppFontSize.body,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                  ),
                                                  onTextChange: (updatedText) {
                                                    // Don't allow changes from this view
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDateTime(
                                                  note.updateTime ?? note.createTime,
                                                ),
                                                style: TextStyle(
                                                  fontSize: AppFontSize.caption,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Image thumbnails grid if available (up to 9 images in 3x3 grid)
                                        if (note.images.isNotEmpty)
                                          FutureBuilder<List<String>>(
                                            future: _getImagePaths(note.id, note.images.take(9).toList()), // Limit to first 9 images
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                                final imagePaths = snapshot.data!;
                                                return Container(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: _buildImagesGrid(imagePaths),
                                                );
                                              } else {
                                                // If image paths couldn't be retrieved, don't show any images
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the note detail screen with the current notebook ID
          Get.to(() => NoteDetailScreen(notebookId: widget.notebookId))?.then((
            value,
          ) {
            if (value == true) {
              _loadNotes(); // Refresh the notes list
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date';
    }
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

  Widget _buildImagesGrid(List<String> imagePaths) {
    // Show up to 9 images in a grid (3x3 max)
    final imagesToShow = imagePaths.length > 9 ? imagePaths.take(9).toList() : imagePaths;

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
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: 1.0, // Square aspect ratio
      ),
      itemCount: imagesToShow.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Show image in fullscreen when tapped (not navigating to note detail)
            _showFullscreenImage(context, imagesToShow[index]);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
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
}
