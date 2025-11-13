import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'note_detail_screen.dart';
import '../controllers/note_controller.dart';
import 'design_system/design_system.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({Key? key}) : super(key: key);

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
                          // Creation time in top-left corner
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              AppPadding.medium.left, 
                              AppPadding.medium.top, 
                              AppPadding.medium.right, 
                              AppPadding.small.bottom, // Reduced bottom padding to reduce gap with content
                            ),
                            child: Text(
                              _formatDateTime(note.createdAt),
                              style: TextStyle(
                                fontSize: AppFontSize.small,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                              AppPadding.medium.bottom, // No top padding to reduce gap from time
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Main content
                                Text(
                                  () {
                                    String contentWithoutChecklist =
                                        _getContentWithoutChecklistItems(
                                          note.content,
                                        );
                                    return contentWithoutChecklist.length > 50
                                        ? '${contentWithoutChecklist.substring(0, 50)}...'
                                        : contentWithoutChecklist;
                                  }(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Display checklist items if any
                                ..._buildChecklistItems(note, context),
                                if (note.tags.isNotEmpty)
                                  Wrap(
                                    spacing: 4.0,
                                    runSpacing: 2.0,
                                    children: note.tags
                                        .map(
                                          (tag) => Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Chip(
                                              label: Text(
                                                tag,
                                                style: TextStyle(
                                                  fontSize: AppFontSize.caption,
                                                ),
                                              ),
                                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                            ),
                                          ),
                                        )
                                        .toList(),
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

  // Extract content without checklist items
  String _getContentWithoutChecklistItems(String content) {
    List<String> lines = content.split('\n');
    List<String> nonChecklistLines = [];

    for (String line in lines) {
      // Skip lines that are checklist items
      if (!line.trim().startsWith('- [') || !line.contains('] ')) {
        nonChecklistLines.add(line);
      }
    }

    // Join the remaining lines and return first 200 characters to avoid overly long text
    String result = nonChecklistLines.join('\n').trim();
    return result.length > 200 ? '${result.substring(0, 200)}...' : result;
  }

  // Extract checklist items from the content and display them as interactive checkboxes
  List<Widget> _buildChecklistItems(Memo note, BuildContext context) {
    // For now, we'll just display any stored checklist states from the memo
    List<Widget> checklistWidgets = [];

    // Create a map of checklist states that can be modified
    Map<int, bool> mutableChecklistStates = Map.from(note.checklistStates);

    // Add any checklist items that are present in the content
    List<String> lines = note.content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.startsWith('- [') && line.contains('] ')) {
        // Extract checkbox state
        bool isChecked = line.substring(3, 4) == 'x';
        String taskContent = line.substring(6); // Skip "- [x] " or "- [ ] "

        // Create a unique key for this checklist item based on content and position
        int key = _generateChecklistKey(taskContent, i);

        // Use stored state if available, otherwise use parsed state
        bool currentState = mutableChecklistStates.containsKey(key)
            ? mutableChecklistStates[key]!
            : isChecked;

        checklistWidgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0), // Standard padding to match text lineHeight
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align with text baseline
              children: [
                Checkbox(
                  value: currentState,
                  onChanged: (bool? newValue) async {
                    if (newValue == null) return;

                    // Update the checklist state
                    mutableChecklistStates[key] = newValue;

                    try {
                      final controller = Get.find<NoteController>();
                      // Update the specific checklist item
                      await controller.updateChecklistItem(
                        note.id,
                        key,
                        taskContent,
                        newValue,
                      );

                      // Update the local state to reflect the change
                      mutableChecklistStates[key] = newValue;

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
                  },
                  visualDensity: VisualDensity.compact, // Reduce checkbox size
                  shape: RoundedRectangleBorder( // Smaller checkbox shape
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                SizedBox(width: 2), // Standard spacing to text
                Expanded(
                  child: Text(
                    taskContent,
                    style: TextStyle(
                      fontSize: AppFontSize.body,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return checklistWidgets;
  }

  // Generate a unique key for a checklist item
  int _generateChecklistKey(String content, int position) {
    return content.hashCode + position;
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
