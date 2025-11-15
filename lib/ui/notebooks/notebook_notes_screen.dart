import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:mindlog/features/memos/presentation/screens/note_detail_screen.dart';
import 'package:mindlog/ui/design_system/design_system.dart';
import 'package:mindlog/ui/notebooks/notebook_detail_screen.dart';

class NotebookNotesScreen extends StatefulWidget {
  final String notebookId;

  const NotebookNotesScreen({Key? key, required this.notebookId})
    : super(key: key);

  @override
  State<NotebookNotesScreen> createState() => _NotebookNotesScreenState();
}

class _NotebookNotesScreenState extends State<NotebookNotesScreen> {
  late NotebookController _notebookController;
  late NoteController _noteController;
  List<Memo> _notes = [];
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
      appBar: AppBar(
        title: Text(_notebook?.title ?? 'Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to the notebook edit screen
              final result = await Get.to(
                () => NotebookDetailScreen(notebookId: widget.notebookId),
              );
              if (result == true) {
                // Refresh the notebook info if it was updated
                await _loadNotebook();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                                margin: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(
                                    note.content.length > 50
                                        ? '${note.content.substring(0, 50)}...'
                                        : note.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    _formatDateTime(
                                      note.updatedAt ?? note.createdAt,
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
