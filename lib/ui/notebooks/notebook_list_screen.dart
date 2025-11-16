import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:mindlog/ui/notebooks/notebook_detail_screen.dart';
import 'package:mindlog/ui/notebooks/notebook_notes_screen.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
import 'package:mindlog/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:mindlog/ui/design_system/design_system.dart';

class NotebookListScreen extends StatelessWidget {
  const NotebookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotebookController>(
      init: NotebookController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Implement search functionality
                  Get.snackbar('Search', 'Search functionality coming soon');
                },
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading && controller.notebooks.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.notebooks.isEmpty) {
              return Center(
                child: Text(
                  'No notebooks yet.\nTap + to create your first notebook.',
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
                await controller.loadNotebooks();
                return; // Required for the refresh indicator
              },
              child: GridView.builder(
                padding: AppPadding.large,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 notebooks per row
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.8, // Make items slightly taller than wide
                ),
                itemCount: controller.notebooks.length,
                itemBuilder: (context, index) {
                  final notebook = controller.notebooks[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.card,
                      side: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: AppBorderRadius.card,
                      onTap: () {
                        Get.to(
                          () => NotebookNotesScreen(
                            notebookId: notebook.id,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover image or placeholder
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12.0),
                                ),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                              child:
                                  notebook.coverImage != null &&
                                      notebook.coverImage!.isNotEmpty
                                  ? Image.asset(
                                      'assets/images/placeholder.jpg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Icon(
                                      Icons.book_outlined,
                                      size: 48.0,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                            ),
                          ),
                          // Notebook title
                          Padding(
                            padding: AppPadding.medium,
                            child: Text(
                              notebook.title,
                              style: TextStyle(
                                fontSize: AppFontSize.body,
                                fontWeight: AppFontWeight.medium,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Notebook type and edit button
                          Padding(
                            padding: EdgeInsets.only(
                              left: AppPadding.medium.left,
                              right: AppPadding.medium.right,
                              bottom: AppPadding.medium.bottom,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notebook.type.toString().split('.').last,
                                  style: TextStyle(
                                    fontSize: AppFontSize.caption,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    // Stop propagation to prevent triggering the parent onTap
                                    Get.to(
                                      () => NotebookDetailScreen(
                                        notebookId: notebook.id,
                                      ),
                                    )?.then((value) {
                                      if (value == true) {
                                        // Refresh the notebook list if a notebook was saved
                                        NotebookController controller =
                                            Get.find<NotebookController>();
                                        controller.loadNotebooks();
                                      }
                                    });
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
              // Navigate to create a new notebook
              Get.to(() => const NotebookDetailScreen(notebook: null))?.then((
                value,
              ) {
                if (value == true) {
                  // Refresh the notebook list if a notebook was saved
                  NotebookController controller =
                      Get.find<NotebookController>();
                  controller.loadNotebooks();
                }
              });
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
