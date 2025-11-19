import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/ui/notebooks/notebook_detail_screen.dart';
import 'package:mindlog/ui/notebooks/notebook_notes_screen.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
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
              child: ListView.builder(
                padding: AppPadding.small,
                itemCount: controller.notebooks.length,
                itemBuilder: (context, index) {
                  final notebook = controller.notebooks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // Reduced margins
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
                      child: Container(
                        padding: const EdgeInsets.all(8.0), // Small padding for the whole item
                        child: Row(
                          children: [
                            // Cover image with minimal size
                            Container(
                              width: 50, // Small fixed width
                              height: 50, // Small fixed height
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0), // Small border radius
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                              child: notebook.coverImage != null &&
                                  notebook.coverImage!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0), // Small border radius
                                      child: Image.network(
                                        notebook.coverImage!,
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        errorBuilder: (context, error, stackTrace) {
                                          // If image fails to load, show smaller placeholder
                                          return Icon(
                                            Icons.book_outlined,
                                            size: 18.0, // Even smaller icon
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.book_outlined,
                                      size: 18.0, // Even smaller icon
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                            ),
                            const SizedBox(width: 8), // Small gap between image and text
                            // Notebook title and type
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notebook.title,
                                    style: TextStyle(
                                      fontSize: AppFontSize.small, // Small font size
                                      fontWeight: AppFontWeight.medium,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2), // Minimal spacing
                                  Text(
                                    notebook.type.toString().split('.').last,
                                    style: TextStyle(
                                      fontSize: AppFontSize.extraSmall, // Small text for category
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 16, // Small edit icon
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
