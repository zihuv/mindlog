import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:mindlog/features/notebooks/domain/entities/notebook.dart';
import 'package:mindlog/controllers/notebooks/notebook_controller.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:mindlog/features/notes/presentation/widgets/note_card.dart';
import 'package:mindlog/ui/design_system/design_system.dart';
import 'package:mindlog/utils/log_util.dart';

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
    return Scaffold(
      appBar: null, // Remove the AppBar as requested
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadNotes();
                },
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      // Notebook title as a header with back button
                      SliverToBoxAdapter(
                        child: Container(
                          width: double.infinity,
                          height: 40, // Very compact height
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: Theme.of(context).appBarTheme.backgroundColor,
                            boxShadow: AppBoxShadow.appBar,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 20,
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () {
                                    Get.back(); // Navigate back to previous screen
                                  },
                                ),
                              ),
                              const Gap(4.0),
                              Expanded(
                                child: Text(
                                  _notebook?.title ?? 'Notes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: AppFontWeight.medium,
                                    color: Theme.of(
                                      context,
                                    ).appBarTheme.titleTextStyle?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const Gap(8.0),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: _notes.isEmpty
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
                                  () => NoteDetailScreen(
                                    noteId: note.id,
                                  ),
                                )?.then((value) {
                                  if (value == true) {
                                    _loadNotes(); // Refresh the notes list after editing
                                  }
                                });
                              },
                              onDelete: null, // No delete option in notebook view for now
                            );
                          },
                        ),
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
