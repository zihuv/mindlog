import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/data/models/notebook.dart';
import 'package:mindlog/presentation/controllers/notebook_controller.dart';
import 'package:mindlog/presentation/controllers/note_controller.dart';
import 'package:mindlog/data/models/note.dart';
import 'package:mindlog/presentation/views/note/note_detail_screen.dart';
import 'package:mindlog/presentation/widgets/note/note_card.dart';
import 'package:mindlog/core/design_system/design_system.dart';
import 'package:mindlog/utils/log_util.dart';
import 'check_in_calendar_screen.dart';
import 'package:mindlog/presentation/widgets/common/custom_header_bar.dart';

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
        setState(() {
          _notebook = notebook;
        });
      } else {
        // Notebook not found, show error
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notebook not found'),
                duration: Duration(seconds: 2),
              ),
            );
            // Navigate back after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          }
        });
      }
    } catch (e) {
      logger.error('Error loading notebook: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading notebook info: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await _noteController.getNotesByNotebookId(
        widget.notebookId,
      );
      if (mounted) {
        setState(() {
          _notes = notes;
        });
      }
    } catch (e) {
      logger.error('Error loading notes: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading notes: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the notebook type is checkIn, show the calendar view
    if (_notebook?.type == NotebookType.checkIn) {
      return CheckInCalendarScreen(notebookId: widget.notebookId);
    }

    return Scaffold(
      appBar: CustomHeaderBar(
        title: _notebook?.title ?? 'Notes',
        showBackButton: true,
      ),
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
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
                          return NoteCard(
                            note: note,
                            onEdit: () {
                              Get.to(
                                () => NoteDetailScreen(noteId: note.id),
                              )?.then((value) {
                                if (value == true) {
                                  _loadNotes(); // Refresh the notes list after editing
                                }
                              });
                            },
                            onDelete:
                                null, // No delete option in notebook view for now
                          );
                        },
                      ),
              ),
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
}
