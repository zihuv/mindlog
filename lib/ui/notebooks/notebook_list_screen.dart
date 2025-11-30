import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/ui/notebooks/notebook_detail_screen.dart';
import 'package:mindlog/ui/notebooks/notebook_notes_screen.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
import 'package:mindlog/ui/design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/webdav_util.dart';

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
                icon: const Icon(Icons.cloud_sync),
                onPressed: () async {
                  // Import webdav util and perform sync
                  try {
                    // Load settings from shared preferences
                    final prefs = await SharedPreferences.getInstance();
                    String url = prefs.getString('webdav_url') ?? '';
                    String username = prefs.getString('webdav_username') ?? '';
                    String password = prefs.getString('webdav_password') ?? '';
                    String folder = prefs.getString('webdav_folder') ?? 'mindlog';

                    if (url.isEmpty || username.isEmpty || password.isEmpty) {
                      // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
                      ScaffoldMessenger.of(Get.context!).showSnackBar(
                        const SnackBar(
                          content: Text('Please configure WebDAV settings first'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    WebDAVConfig config = WebDAVConfig(
                      url: url,
                      username: username,
                      password: password,
                      folderName: folder,
                    );

                    // Show progress indicator
                    final progress = Get.dialog(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Get.theme.dialogTheme.backgroundColor ?? Get.theme.canvasColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 20),
                              const Text(
                                'Syncing with WebDAV...',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      barrierDismissible: false,
                    );

                    WebDAVUtil webdavUtil = WebDAVUtil();
                    await webdavUtil.init(config);
                    await webdavUtil.sync();

                    // Close progress dialog
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }

                    // Show success message
                    ScaffoldMessenger.of(Get.context!).showSnackBar(
                      const SnackBar(
                        content: Text('Sync completed successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    webdavUtil.dispose();
                  } catch (e) {
                    // Close progress dialog if still open
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }

                    // Show error message
                    ScaffoldMessenger.of(Get.context!).showSnackBar(
                      SnackBar(
                        content: Text('Sync failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Implement search functionality
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
                    ScaffoldMessenger.of(Get.context!).showSnackBar(
                      const SnackBar(content: Text('Search functionality coming soon')),
                    );
                  });
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ), // Reduced margins
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
                          () => NotebookNotesScreen(notebookId: notebook.id),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                          8.0,
                        ), // Small padding for the whole item
                        child: Row(
                          children: [
                            // Cover image with minimal size
                            Container(
                              width: 50, // Small fixed width
                              height: 50, // Small fixed height
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  6.0,
                                ), // Small border radius
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                              child:
                                  notebook.coverImage != null &&
                                      notebook.coverImage!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        6.0,
                                      ), // Small border radius
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
                            const SizedBox(
                              width: 8,
                            ), // Small gap between image and text
                            // Notebook title and type
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notebook.title,
                                    style: TextStyle(
                                      fontSize:
                                          AppFontSize.small, // Small font size
                                      fontWeight: AppFontWeight.medium,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2), // Minimal spacing
                                  Text(
                                    notebook.type.toString().split('.').last,
                                    style: TextStyle(
                                      fontSize: AppFontSize
                                          .extraSmall, // Small text for category
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
