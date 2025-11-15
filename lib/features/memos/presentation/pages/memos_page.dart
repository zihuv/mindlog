import 'package:flutter/material.dart';
import 'package:mindlog/features/memos/data/memo_service.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';
import 'package:mindlog/features/memos/presentation/widgets/memo_card.dart';
import 'package:mindlog/features/memos/presentation/widgets/memo_editor_screen.dart';

import 'package:mindlog/features/settings/presentation/pages/settings_page.dart';
import 'package:mindlog/features/journal/presentation/pages/journal_page.dart';

class MemosPage extends StatefulWidget {
  const MemosPage({super.key});

  @override
  State<MemosPage> createState() => _MemosPageState();
}

class _MemosPageState extends State<MemosPage> {
  List<Memo> _allMemos = [];
  List<Memo> _filteredMemos = [];
  List<String> _allTags = [];
  List<String> _selectedTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    try {
      _allMemos = await MemoService.instance.getAllMemos();
      _filteredMemos = _allMemos; // No tag filtering since tags are removed
      _sortMemos();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading memos: $e');
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

  void _filterMemosByTags(List<String> selectedTags) {
    // Since tags have been removed, just return all memos
    _filteredMemos = _allMemos;
    _sortMemos();
    setState(() {
      _selectedTags = []; // Clear selected tags since they're removed
    });
  }

  void _sortMemos() {
    // Sort by pinned first, then by creation date (newest first)
    _filteredMemos.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  void _addMemo() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoEditorScreen(
          onSave: (memo) async {
            setState(() {
              _allMemos.insert(0, memo);
              _filteredMemos = _allMemos;
              _sortMemos();
            });
            // Refresh tags list after adding a memo
            _loadTags();
          },
        ),
      ),
    );
  }

  void _editMemo(Memo memo) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoEditorScreen(
          initialMemo: memo,
          isEdit: true,
          onSave: (updatedMemo) async {
            setState(() {
              int index = _allMemos.indexWhere((m) => m.id == updatedMemo.id);
              if (index != -1) {
                _allMemos[index] = updatedMemo;
                _filteredMemos = _allMemos; // Update the filtered list
                _sortMemos();
              }
            });
            // Tags have been removed from this refactor
          },
        ),
      ),
    );
  }

  void _deleteMemo(Memo memo) async {
    // Show confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Memo'),
        content: const Text('Are you sure you want to delete this memo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await MemoService.instance.deleteMemo(memo.id);
        setState(() {
          _allMemos.removeWhere((m) => m.id == memo.id);
          _filteredMemos.removeWhere((m) => m.id == memo.id);
        });
        // Tags have been removed from this refactor
      } catch (e) {
        print('Error deleting memo: $e');
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting memo: $e'),
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
              'Memos',
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
              title: const Text('Memos'),
              onTap: () {
                // Already on memos page, just close drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Journal'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const JournalPage()),
                );
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
                : _allMemos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_add, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No memos yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to create your first memo',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )

                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadMemos();
                    },
                    child: ListView.builder(
                      itemCount: _filteredMemos.length,
                      itemBuilder: (context, index) {
                        final memo = _filteredMemos[index];
                        return MemoCard(
                          memo: memo,
                          onTap: () {
                            // Single tap could be for selecting or expanding
                            // For now, let's just keep it as a tap indicator if needed
                            // or potentially expand/collapse functionality
                          },
                          onEdit: () => _editMemo(memo),
                          onDelete: () => _deleteMemo(memo),
                          onChecklistChanged: (updatedMemo) async {
                            // Save the updated memo with new checklist states
                            await MemoService.instance.updateMemo(updatedMemo);

                            // Update the local list
                            setState(() {
                              int index = _allMemos.indexWhere(
                                (m) => m.id == updatedMemo.id,
                              );
                              if (index != -1) {
                                _allMemos[index] = updatedMemo;
                                _filteredMemos = _allMemos; // Update the filtered list
                                _sortMemos();
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
        onPressed: _addMemo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
