import 'package:get/get.dart';
import 'package:mindlog/features/notebooks/notebook_service.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:image_picker/image_picker.dart';

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
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadNotebooks() async {
    _isLoading.value = true;
    try {
      final notebooks = await _service.getAllNotebooks();
      // Sort notebooks by creation time in descending order (newest first)
      notebooks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _notebooks.assignAll(notebooks);
    } catch (e) {
      Get.log('Error loading notebooks: $e');
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      Get.rawSnackbar(
        title: "Error",
        message: "Error loading notebooks: $e",
        duration: const Duration(seconds: 3),
      );
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
    final notebook = Notebook(
      id: '',
      title: title,
      description: description,
      coverImage: coverImage,
      type: type,
      createdAt: DateTime.now(),
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
        updatedAt: DateTime.now(),
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
      // In a real implementation, you would save the image and return the path
      // For now, we just return the path of the picked image
      return image.path;
    }
    return null;
  }

  @override
  void onClose() {
    _service.close();
    super.onClose();
  }
}
