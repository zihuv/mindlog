import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'note_detail_screen.dart';
import '../../../../controllers/note_controller.dart';
import '../../../../ui/design_system/design_system.dart';
import '../components/components/markdown_checklist.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NoteController>(
      init: NoteController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Notes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final query = await showSearch<String>(
                    context: context,
                    delegate: _NoteSearchDelegate(),
                  );

                  if (query != null) {
                    await controller.searchNotes(query);
                  }
                },
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading && controller.notes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.notes.isEmpty) {
              return Center(
                child: Text(
                  'No notes yet.\nTap + to create your first note.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontSize.large,
                    fontWeight: AppFontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await controller.loadNotes();
                return; // Required for the refresh indicator
              },
              child: ListView.builder(
                itemCount: controller.notes.length,
                itemBuilder: (context, index) {
                  final note = controller.notes[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => NoteDetailScreen(noteId: note.id));
                    },
                    child: Card(
                      margin: AppPadding.small,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Modification createTime in top-left corner (creation createTime if no modifications)
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              AppPadding.medium.left,
                              AppPadding.medium.top,
                              AppPadding.medium.right,
                              AppPadding
                                  .small
                                  .bottom, // Reduced bottom padding to reduce gap with content
                            ),
                            child: Text(
                              _formatDateTime(note.createTime),
                              style: TextStyle(
                                fontSize: AppFontSize.small,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: AppFontWeight.medium,
                              ),
                            ),
                          ),
                          // Content area with consistent padding
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              AppPadding.large.left,
                              0.0,
                              AppPadding.large.right,
                              AppPadding
                                  .medium
                                  .bottom, // No top padding to reduce gap from createTime
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display image thumbnails if available
                                if (note.images.isNotEmpty)
                                  Container(
                                    height: 80, // Fixed height for image container
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: note.images.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 8.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                // Navigate to detail view to see the image
                                                Get.to(() => NoteDetailScreen(noteId: note.id));
                                              },
                                              child: FutureBuilder<String?>(
                                                future: _getImagePath(note.id, note.images[index]),
                                                builder: (context, snapshot) {
                                                  print('Image FutureBuilder - Note: ${note.id}, Index: $index, HasData: ${snapshot.hasData}, Data: ${snapshot.data}');
                                                  if (snapshot.hasData && snapshot.data != null) {
                                                    return Image.file(
                                                      File(snapshot.data!),
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                    );
                                                  } else {
                                                    print('Image FutureBuilder - No data for note: ${note.id}, image: ${note.images[index]}');
                                                    return Container(
                                                      width: 80,
                                                      height: 80,
                                                      color: Theme.of(context).dividerColor,
                                                      child: Icon(
                                                        Icons.image,
                                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                // Main content with markdown checklist support
                                MarkdownChecklist(
                                  text: note.content.length > 200
                                      ? '${note.content.substring(0, 200)}...'
                                      : note.content,
                                  style: TextStyle(
                                    fontSize: AppFontSize.body,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  onTextChange: (updatedText) {
                                    _updateNoteContent(note.id, updatedText);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(() => const NoteDetailScreen(noteId: null))?.then((value) {
                // Refresh list after creating/updating
                if (value == true) {
                  controller.loadNotes();
                }
              });
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date';
    }
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Update the note content when checklist items are toggled
  Future<void> _updateNoteContent(String noteId, String newContent) async {
    try {
      final controller = Get.find<NoteController>();
      await controller.updateNote(id: noteId, content: newContent);
      // Refresh the notes list to reflect the updated content
      await controller.loadNotes();
    } on Exception catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Error updating checklist: $e',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Unexpected error updating checklist: $e',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
    }
  }
}

class _NoteSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // This method is called when the search is submitted
    // For simplicity, we'll trigger the search from NoteListScreen
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Enter a search term',
          style: TextStyle(
            fontSize: AppFontSize.large,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }
    // Search is handled by NoteListScreen, not in the delegate
    return Center(
      child: Text(
        'Performing search...',
        style: TextStyle(
          fontSize: AppFontSize.large,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions based on query if needed
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Enter a search term',
          style: TextStyle(
            fontSize: AppFontSize.large,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    } else {
      return Center(
        child: Text(
          'Search for: "$query"',
          style: TextStyle(
            fontSize: AppFontSize.large,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }
  }
}

// Helper function to get the full path of an image
Future<String?> _getImagePath(String noteId, String imageName) async {
  try {
    // According to MediaService implementation, images are stored in {appDir}/{mediaType}/{noteId}/{imageName}
    final appDir = await getApplicationDocumentsDirectory();
    String imagePath = path.join(appDir.path, 'images', noteId, imageName);

    // Debugging: Print the path being checked
    print('Checking for image at path: $imagePath');
    bool exists = File(imagePath).existsSync();
    print('Image exists: $exists');

    return exists ? imagePath : null;
  } on Exception catch (e) {
    print('Error getting image path: $e');
    return null;
  }
}
