import 'package:flutter/material.dart';
import 'package:mindlog/features/notes/data/note_service.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/presentation/widgets/note_card.dart';
import 'package:mindlog/features/notes/presentation/widgets/note_editor_screen.dart';

import 'package:mindlog/features/settings/presentation/pages/settings_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  List<String> _allTags = [];
  List<String> _selectedTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      _allNotes = await NoteService.instance.getAllNotes();
      _filteredNotes = _allNotes; // No tag filtering since tags are removed
      _sortNotes();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTags() async {
    // Tag functionality has been removed in this refactor
    // Keeping this as an empty implementation to maintain compatibility
    _allTags = [];
    setState(() {});
  }

  void _filterNotesByTags(List<String> selectedTags) {
    // Since tags have been removed, just return all notes
    _filteredNotes = _allNotes;
    _sortNotes();
    setState(() {
      _selectedTags = []; // Clear selected tags since they're removed
    });
  }

  void _sortNotes() {
    // Sort by pinned first, then by creation date (newest first)
    _filteredNotes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  void _addNote() async {
    final contextLocal = context; // Capture context before async call
    Navigator.push(
      contextLocal,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          onSave: (note) async {
            setState(() {
              _allNotes.insert(0, note);
              _filteredNotes = _allNotes;
              _sortNotes();
            });
            // Refresh tags list after adding a note
            _loadTags();
          },
        ),
      ),
    );
  }

  void _editNote(Note note) async {
    final contextLocal = context; // Capture context before async call
    Navigator.push(
      contextLocal,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          initialNote: note,
          isEdit: true,
          onSave: (updatedNote) async {
            setState(() {
              int index = _allNotes.indexWhere((m) => m.id == updatedNote.id);
              if (index != -1) {
                _allNotes[index] = updatedNote;
                _filteredNotes = _allNotes; // Update the filtered list
                _sortNotes();
              }
            });
            // Tags have been removed from this refactor
          },
        ),
      ),
    );
  }

  void _deleteNote(Note note) async {
    final contextLocal = context; // Capture context before any async calls

    // Show confirmation dialog
    bool confirm = await showDialog(
      context: contextLocal,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await NoteService.instance.deleteNote(note.id);
        setState(() {
          _allNotes.removeWhere((m) => m.id == note.id);
          _filteredNotes.removeWhere((m) => m.id == note.id);
        });
        // Tags have been removed from this refactor
      } catch (e) {
        print('Error deleting note: $e');
        // Show error snackbar
        ScaffoldMessenger.of(contextLocal).showSnackBar(
          SnackBar(
            content: Text('Error deleting note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            const Text(
              'Notes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                'MindLog',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notes'),
              onTap: () {
                // Already on notes page, just close drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allNotes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_add, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No notes yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to create your first note',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )

                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadNotes();
                    },
                    child: ListView.builder(
                      itemCount: _filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = _filteredNotes[index];
                        return NoteCard(
                          note: note,
                          onTap: () {
                            // Single tap could be for selecting or expanding
                            // For now, let's just keep it as a tap indicator if needed
                            // or potentially expand/collapse functionality
                          },
                          onEdit: () => _editNote(note),
                          onDelete: () => _deleteNote(note),
                          onChecklistChanged: (updatedNote) async {
                            // Save the updated note with new checklist states
                            await NoteService.instance.updateNote(updatedNote);

                            // Update the local list
                            setState(() {
                              int index = _allNotes.indexWhere(
                                (m) => m.id == updatedNote.id,
                              );
                              if (index != -1) {
                                _allNotes[index] = updatedNote;
                                _filteredNotes = _allNotes; // Update the filtered list
                                _sortNotes();
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
