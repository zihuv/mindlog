import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:mindlog/ui/design_system/design_system.dart';
import 'package:mindlog/features/notes/presentation/components/components/markdown_checklist.dart';

class NotebookNotesScreen extends StatefulWidget {
  final String notebookId;

  const NotebookNotesScreen({super.key, required this.notebookId});

  @override
  State<NotebookNotesScreen> createState() => _NotebookNotesScreenState();
}

class _NotebookNotesScreenState extends State<NotebookNotesScreen> {
  late NotebookController _notebookController;
  late NoteController _noteController;
  List<Note> _notes = [];
  Notebook? _notebook;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notebookController = Get.isRegistered<NotebookController>()
        ? Get.find<NotebookController>()
        : Get.put(NotebookController());
    _noteController = Get.isRegistered<NoteController>()
        ? Get.find<NoteController>()
        : Get.put(NoteController());

    _loadNotebook();
    _loadNotes();
  }

  Future<void> _loadNotebook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notebook = await _notebookController.getNotebookById(
        widget.notebookId,
      );
      if (notebook != null) {
        _notebook = notebook;
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Error loading notebook info: $e',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _notes = await _noteController.getNotesByNotebookId(widget.notebookId);
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'Error loading notes: $e',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Remove the AppBar as requested
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Notebook title as a header with back button
                Container(
                  width: double.infinity,
                  padding: AppPadding.medium,
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    boxShadow: AppBoxShadow.appBar,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Get.back(); // Navigate back to previous screen
                        },
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _notebook?.title ?? 'Notes',
                          style: TextStyle(
                            fontSize: AppFontSize.large,
                            fontWeight: AppFontWeight.medium,
                            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Notes list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _loadNotes();
                    },
                    child: _notes.isEmpty
                        ? const Center(
                            child: Text(
                              'No notes yet',
                              style: TextStyle(
                                fontSize: AppFontSize.body,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              final note = _notes[index];
                              return Card(
                                margin: AppPadding.small,
                                child: ListTile(
                                  contentPadding: AppPadding.medium,
                                  title: Container(
                                    constraints: const BoxConstraints(
                                      maxHeight: 60, // Limit height to 2 lines
                                    ),
                                    child: SingleChildScrollView(
                                      child: MarkdownChecklist(
                                        text: note.content.length > 50
                                            ? '${note.content.substring(0, 50)}...'
                                            : note.content,
                                        style: TextStyle(
                                          fontSize: AppFontSize.body,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        onTextChange: (updatedText) {
                                          // Don't allow changes from this view
                                        },
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    _formatDateTime(
                                      note.updateTime ?? note.createTime,
                                    ),
                                    style: TextStyle(
                                      fontSize: AppFontSize.caption,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  onTap: () {
                                    Get.to(
                                      () => NoteDetailScreen(noteId: note.id),
                                    )?.then((value) {
                                      if (value == true) {
                                        _loadNotes(); // Refresh the notes list after editing
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the note detail screen with the current notebook ID
          Get.to(() => NoteDetailScreen(notebookId: widget.notebookId))?.then((
            value,
          ) {
            if (value == true) {
              _loadNotes(); // Refresh the notes list
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date';
    }
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
