import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mindlog/services/data_export_service.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
import 'package:mindlog/database/app_database.dart' as db;
import 'package:mindlog/features/notes/data/note_service.dart';
import 'package:mindlog/features/notebooks/notebook_service.dart';
import 'package:mindlog/utils/log_util.dart';

class BackupScreen extends StatelessWidget {
  final DataExportService _exportService = DataExportService();

  BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Backup',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildExportCard(context),
            const SizedBox(height: 16),
            _buildImportCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a backup of your notes and media files',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _exportData,
              icon: const Icon(Icons.download),
              label: const Text('Export Backup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Restore notes and media files from a backup',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _importData,
              icon: const Icon(Icons.upload),
              label: const Text('Import Backup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() async {
    try {
      // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text('Starting data export...')),
      );

      bool exportSuccess = await _exportService.exportDataToZipWithSaveDialog();

      if (exportSuccess) {
        // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // User cancelled the save dialog
        // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text('Export was cancelled by the user.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importData() async {
    // Progress tracking variables
    final progress = 0.0.obs;
    final progressMessage = 'Starting import...'.obs;
    try {
      // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text('Select a backup file to import...')),
      );

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withReadStream: false, // Set to false to get the file path
      );

      if (result == null || result.files.single.path == null) {
        // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text('No file selected.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String filePath = result.files.single.path!;
      
      // Show progress dialog
      Get.dialog(
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
                const Text(
                  'Importing Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Obx(() => LinearProgressIndicator(
                      value: progress.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    )),
                const SizedBox(height: 20),
                Obx(() => Text(progressMessage.value)),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Perform the import with progress callback
      await _exportService.importDataFromZip(filePath, onProgress: (double p) async {
        progress.value = p;
        if (p < 0.1) {
          progressMessage.value = 'Reading backup file...';
        } else if (p < 0.3) {
          progressMessage.value = 'Importing database...';
        } else if (p < 0.9) {
          progressMessage.value = 'Importing media files...';
        } else {
          progressMessage.value = 'Finalizing import...';
        }
        
        // Small delay to allow UI updates
        await Future.delayed(const Duration(milliseconds: 10));
      });
      
      // Close the progress dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Wait for the database connection to be properly reinitialized
      await Future.delayed(const Duration(milliseconds: 500));

      // Force reinitialization of database provider
      await db.DatabaseProvider.instance.reset();
      
      // Reset services to force re-initialization with new database
      await NoteService.instance.reset();
      await NotebookService.instance.reset();
      
      // Add another delay to ensure database is fully reset
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Refresh the controllers to reload data from the database
      // Use try-catch to handle cases where controllers might not be ready yet
      try {
        final noteController = Get.find<NoteController>();
        // Close the controller to force re-initialization
        noteController.onClose();
        // Re-initialize the controller
        await noteController.initialize();
        await noteController.loadNotes();
      } catch (e) {
        logger.error('NoteController refresh error: $e');
      }

      try {
        final notebookController = Get.find<NotebookController>();
        // Close the controller to force re-initialization
        notebookController.onClose();
        // Re-initialize the controller
        await notebookController.initialize();
        await notebookController.loadNotebooks();
      } catch (e) {
        logger.error('NotebookController refresh error: $e');
      }

      // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('Data imported successfully from: ${filePath.split('/').last}'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to allow the UI to properly refresh
      Get.back();
    } catch (e) {
      // Use ScaffoldMessenger instead of Get.snackbar to avoid Overlay issues
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}