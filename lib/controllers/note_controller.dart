import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../data/services/combined_note_service.dart';
import '../features/notes/domain/entities/note.dart';
import '../utils/log_util.dart';

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
      logger.debug('NoteController.loadNotes: Loading all notes');
      final notes = await _service.getAllNotes();
      logger.debug('NoteController.loadNotes: Retrieved ${notes.length} notes');
      for (int i = 0; i < notes.length; i++) {
        final note = notes[i];
        logger.debug(
          'Note ${i + 1}: id=${note.id}, images=${note.images}, content length=${note.content.length}',
        );
      }
      // Sort notes by creation createTime in descending order (newest first)
      notes.sort((a, b) => b.createTime.compareTo(a.createTime));
      _notes.assignAll(notes);
    } catch (e) {
      Get.log('Error loading notes: $e');
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.rawSnackbar(
          title: "Error",
          message: "Error loading notes: $e",
          duration: const Duration(seconds: 3),
        );
      });
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<Note>> getNotesByNotebookId(String notebookId) async {
    final notes = await _service.getNotesByNotebookId(notebookId);
    // Sort notes by creation createTime in descending order (newest first)
    notes.sort((a, b) => b.createTime.compareTo(a.createTime));
    return notes;
  }

  Future<List<Note>> getNotesByDate(DateTime date) async {
    _isLoading.value = true;
    try {
      final notes = await _service.getNotesByDate(date);
      // Sort notes by creation createTime in descending order (newest first)
      notes.sort((a, b) => b.createTime.compareTo(a.createTime));
      return notes;
    } catch (e) {
      Get.log('Error loading notes by date: $e');
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.rawSnackbar(
          title: "Error",
          message: "Error loading notes by date: $e",
          duration: const Duration(seconds: 3),
        );
      });
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> searchNotes(String query) async {
    _isLoading.value = true;
    try {
      final notes = query.isEmpty
          ? await _service.getAllNotes()
          : await _service.searchNotes(query);

      // Sort notes by creation createTime in descending order (newest first)
      notes.sort((a, b) => b.createTime.compareTo(a.createTime));
      _notes.assignAll(notes);
    } catch (e) {
      Get.log('Error searching notes: $e');
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.rawSnackbar(
          title: "Error",
          message: "Error searching notes: $e",
          duration: const Duration(seconds: 3),
        );
      });
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Note?> getNoteById(String id) async {
    logger.debug('NoteController.getNoteById: $id');
    final note = await _service.getNoteById(id);
    if (note != null) {
      logger.debug(
        'NoteController.getNoteById result: id=${note.id}, images=${note.images}, content length=${note.content.length}',
      );
    } else {
      logger.debug('NoteController.getNoteById: note not found');
    }
    return note;
  }

  Future<String> createNote({
    required String content,
    String? notebookId,
  }) async {
    return await _service.createNote(content: content, notebookId: notebookId);
  }

  Future<void> updateNote({
    required String id,
    String? content,
    String? notebookId,
  }) async {
    await _service.updateNote(id: id, content: content, notebookId: notebookId);
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

      await updateNote(id: noteId, content: updatedContent);
    }
  }

  // Add image to a note
  Future<void> addImageToNote({
    required String noteId,
    required String imagePath,
    required String content,
  }) async {
    await _service.updateNote(
      id: noteId,
      content: content,
      newImagesToCopy: [imagePath],
    );
  }

  // Update note media (for deletion/replacement)
  Future<void> updateNoteMedia({
    required String noteId,
    List<String>? imageNames,
    List<String>? videoNames,
    List<String>? audioNames,
    String? noteContent,
    String? notebookId,
  }) async {
    await _service.updateNoteMedia(
      id: noteId,
      imageNames: imageNames,
      videoNames: videoNames,
      audioNames: audioNames,
      noteContent: noteContent,
      notebookId: notebookId,
    );
  }

  // Create a note with an image
  Future<String> createNoteWithImage({
    required String content,
    required String imagePath,
    String? notebookId,
  }) async {
    return await _service.createNote(
      content: content,
      imagesToCopy: [imagePath],
      notebookId: notebookId,
    );
  }

  // Helper function to generate consistent keys (same as in UI)
  int _generateChecklistKey(String content, int position) {
    return content.hashCode + position;
  }

  // Refresh the notes list by reloading from the database
  Future<void> refreshNotes() async {
    logger.debug('NoteController.refreshNotes: Refreshing note list');
    _isLoading.value = true;
    try {
      final notes = await _service.getAllNotes();
      logger.debug('NoteController.refreshNotes: Retrieved ${notes.length} notes after refresh');
      // Sort notes by creation createTime in descending order (newest first)
      notes.sort((a, b) => b.createTime.compareTo(a.createTime));
      _notes.assignAll(notes);
    } catch (e) {
      logger.error('Error refreshing notes: $e');
      // Don't show snackbar during import to avoid overlay issues
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _service.close();
    super.onClose();
  }
}
