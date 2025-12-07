import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mindlog/features/notebooks/notebook_service.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mindlog/utils/media_util.dart';
import 'package:mindlog/utils/log_util.dart';

class NotebookController extends GetxController {
  final NotebookService _service = NotebookService();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _notebooks = <Notebook>[].obs;
  List<Notebook> get notebooks => _notebooks.toList();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    _isLoading.value = true;
    try {
      await _service.init();
      await loadNotebooks(); // Load notebooks after initialization
    } on Exception catch (e) {
      Get.log('Initialization error: $e');
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.rawSnackbar(
          title: "Initialization Error",
          message: "Failed to initialize notebook service: $e",
          duration: const Duration(seconds: 3),
        );
      });
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadNotebooks() async {
    _isLoading.value = true;
    try {
      final notebooks = await _service.getAllNotebooks();
      // Sort notebooks by sortIndex (for user-defined order)
      notebooks.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      _notebooks.assignAll(notebooks);
    } catch (e) {
      Get.log('Error loading notebooks: $e');
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.rawSnackbar(
          title: "Error",
          message: "Error loading notebooks: $e",
          duration: const Duration(seconds: 3),
        );
      });
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Notebook?> getNotebookById(String id) async {
    return await _service.getNotebookById(id);
  }

  Future<String> createNotebook({
    required String title,
    String? description,
    String? coverImage,
    NotebookType type = NotebookType.standard,
  }) async {
    final notebooks = await _service.getAllNotebooks();
    final maxSortIndex = notebooks.isNotEmpty
        ? notebooks.map((n) => n.sortIndex).reduce((a, b) => a > b ? a : b)
        : -1;

    final notebook = Notebook(
      id: '',
      title: title,
      description: description,
      coverImage: coverImage,
      type: type,
      sortIndex: maxSortIndex + 1, // Place at the end
      createTime: DateTime.now(),
    );
    return await _service.saveNotebook(notebook);
  }

  Future<void> updateNotebook({
    required String id,
    String? title,
    String? description,
    String? coverImage,
    NotebookType? type,
  }) async {
    final existingNotebook = await getNotebookById(id);
    if (existingNotebook != null) {
      final updatedNotebook = existingNotebook.copyWith(
        title: title ?? existingNotebook.title,
        description: description ?? existingNotebook.description,
        coverImage: coverImage ?? existingNotebook.coverImage,
        type: type ?? existingNotebook.type,
        updateTime: DateTime.now(),
      );
      await _service.updateNotebook(updatedNotebook);
    }
  }

  Future<void> deleteNotebook(String id) async {
    await _service.deleteNotebook(id);
  }

  Future<String?> pickNotebookCoverImage() async {
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      try {
        // Copy image to app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final notebookImagesDir = Directory('${appDir.path}/notebook_images');

        // Create directory if it doesn't exist
        if (!notebookImagesDir.existsSync()) {
          notebookImagesDir.createSync(recursive: true);
        }

        // Generate a unique filename using UUID v7
        final newFileName = MediaUtil.generateImageFilename(image.path);
        final savedImage = await File(
          image.path,
        ).copy('${notebookImagesDir.path}/$newFileName');

        return savedImage.path;
      } catch (e) {
        Get.log('Error copying image: $e');
        // If copying fails, return the original path anyway
        return image.path;
      }
    }
    return null;
  }

  // Refresh the notebooks list by reloading from the database
  Future<void> refreshNotebooks() async {
    _isLoading.value = true;
    try {
      final notebooks = await _service.getAllNotebooks();
      // Sort notebooks by sortIndex (for user-defined order)
      notebooks.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      _notebooks.assignAll(notebooks);
    } catch (e) {
      logger.error('Error refreshing notebooks: $e');
      // Don't show snackbar during import to avoid overlay issues
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reorderNotebooks(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    try {
      // Adjust indices if dragging down (since the item shifts during drag)
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      // Get the notebook being moved
      final notebookToMove = _notebooks.removeAt(oldIndex);

      // Insert it at the new position
      _notebooks.insert(newIndex, notebookToMove);

      // Update sort indices for all notebooks
      // Also update updateTime to ensure sync recognizes the change
      for (int i = 0; i < _notebooks.length; i++) {
        final updatedNotebook = _notebooks[i].copyWith(
          sortIndex: i,
          updateTime: DateTime.now(),
        );
        await _service.updateNotebook(updatedNotebook);
      }

      // Refresh the list to make sure it's in the correct order
      await loadNotebooks();
    } catch (e) {
      Get.log('Error reordering notebooks: $e');
      // Reload notebooks to restore original order if something went wrong
      await loadNotebooks();
    }
  }

  @override
  void onClose() {
    _service.close();
    super.onClose();
  }
}
