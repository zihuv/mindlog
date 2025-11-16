import 'package:get/get.dart';
import '../data/services/combined_note_service.dart';
import '../features/notes/domain/entities/note.dart';

class NoteController extends GetxController {
  final CombinedNoteService _service = CombinedNoteService();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _notes = <Note>[].obs;
  List<Note> get notes => _notes.toList();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    _isLoading.value = true;
    try {
      await _service.init();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadNotes() async {
    _isLoading.value = true;
    try {
      final notes = await _service.getAllNotes();
      // Sort notes by creation time in descending order (newest first)
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _notes.assignAll(notes);
    } catch (e) {
      Get.log('Error loading notes: $e');
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      Get.rawSnackbar(
        title: "Error",
        message: "Error loading notes: $e",
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Note>> getNotesByNotebookId(String notebookId) async {
    return await _service.getNotesByNotebookId(notebookId);
  }

  Future<void> searchNotes(String query) async {
    _isLoading.value = true;
    try {
      final notes = query.isEmpty
          ? await _service.getAllNotes()
          : await _service.searchNotes(query);

      // Sort notes by creation time in descending order (newest first)
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _notes.assignAll(notes);
    } catch (e) {
      Get.log('Error searching notes: $e');
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      Get.rawSnackbar(
        title: "Error",
        message: "Error searching notes: $e",
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Note?> getNoteById(String id) async {
    return await _service.getNoteById(id);
  }

  Future<void> createNote({
    required String content,
    List<String>? tags,
    Map<int, bool>? checklistStates,
    String? notebookId,
  }) async {
    await _service.createNote(
      content: content,
      tags: tags,
      checklistStates: checklistStates,
      notebookId: notebookId,
    );
  }

  Future<void> updateNote({
    required String id,
    String? content,
    List<String>? tags,
    Map<int, bool>? checklistStates,
    String? notebookId,
  }) async {
    await _service.updateNote(
      id: id,
      content: content,
      tags: tags,
      checklistStates: checklistStates,
      notebookId: notebookId,
    );
  }

  Future<void> deleteNote(String id) async {
    await _service.deleteNote(id);
  }

  Future<void> updateChecklistItem(
    String noteId,
    int itemIndex,
    String itemContent,
    bool newValue,
  ) async {
    final note = await getNoteById(noteId);
    if (note != null) {
      // Split the content into lines
      List<String> lines = note.content.split('\n');

      // Find and update the specific checklist item based on position and content
      int checklistPosition = 0;
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.startsWith('- [') && line.contains('] ')) {
          // Extract task content from line
          String lineTaskContent = line.substring(
            line.indexOf('] ') + 2,
          ); // Skip "- [x] " or "- [ ] "

          // Generate key like in the UI to match exactly
          int lineKey = _generateChecklistKey(
            lineTaskContent,
            checklistPosition,
          );

          if (lineKey == itemIndex && lineTaskContent == itemContent) {
            // Update the checkbox state in the line: [ ] becomes [x], [x] becomes [ ]
            String updatedLine = line.replaceFirst(
              RegExp(r'- \[.\]'),
              '- [${newValue ? 'x' : ' '}]',
            );
            // Preserve original indentation
            if (lines[i] != line) {
              // If the original line had indentation, preserve it
              String originalLine = lines[i];
              String indentation = originalLine.substring(
                0,
                originalLine.indexOf(line),
              );
              updatedLine = indentation + updatedLine;
            }

            lines[i] = updatedLine;
            break; // Only update the first match
          }
          checklistPosition++;
        }
      }

      String updatedContent = lines.join('\n');

      // Also update checklistStates map
      Map<int, bool> updatedChecklistStates = Map.from(note.checklistStates);
      updatedChecklistStates[itemIndex] = newValue;

      await updateNote(
        id: noteId,
        content: updatedContent,
        tags: note.tags,
        checklistStates: updatedChecklistStates,
      );
    }
  }

  // Helper function to generate consistent keys (same as in UI)
  int _generateChecklistKey(String content, int position) {
    return content.hashCode + position;
  }

  @override
  void onClose() {
    _service.close();
    super.onClose();
  }
}
