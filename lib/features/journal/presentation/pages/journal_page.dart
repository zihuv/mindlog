import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../domain/entities/journal_entry.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/journal_entry_screen.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<JournalEntry> _journalEntries = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('zh_CN', null);
    _journalEntries = [];
    _sortJournalEntries();
  }

  void _addJournalEntry() {
    // Navigate to the journal entry screen and pass the callback to add entry
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryScreen(
          onSave: (content, mood, entryDate) {
            setState(() {
              _journalEntries.insert(
                0, // Add to the beginning of the list
                JournalEntry(
                  id: DateTime.now().millisecondsSinceEpoch,
                  content: content,
                  dateTime: entryDate,  // Use the entry date provided by the screen
                  mood: mood,
                ),
              );
              _sortJournalEntries();
            });
          },
          initialDate: _selectedDate, // Pass the selected date
        ),
      ),
    );
  }

  void _editJournalEntry(JournalEntry entry) {
    // Navigate to the journal entry screen in edit mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryScreen(
          onSave: (content, mood, entryDate) {
            setState(() {
              // Find the index of the entry to edit
              int index = _journalEntries.indexWhere((e) => e.id == entry.id);
              if (index != -1) {
                // Update the entry content and mood but keep the original time
                _journalEntries[index] = JournalEntry(
                  id: _journalEntries[index].id,
                  content: content,
                  dateTime: _journalEntries[index].dateTime, // Keep the original time
                  mood: mood,
                );
              }
            });
          },
          initialContent: entry.content,
          initialMood: entry.mood,
          initialDate: entry.dateTime, // Pass the original date of the entry
        ),
      ),
    );
  }

  void _sortJournalEntries() {
    _journalEntries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<JournalEntry> _getEntriesForSelectedDate() {
    // Return entries for the selected date
    return _journalEntries.where((entry) {
      return entry.dateTime.year == _selectedDate.year &&
             entry.dateTime.month == _selectedDate.month &&
             entry.dateTime.day == _selectedDate.day;
    }).toList();
  }

  void _showCalendarModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to expand to full height if needed
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1),
                  // Calendar widget
                  Expanded(
                    child: CalendarWidget(
                      selectedDate: _selectedDate,
                      onDateSelected: (selectedDate) {
                        _filterEntriesByDate(selectedDate);
                        Navigator.pop(context); // Close the modal after selection
                      },
                      isExpanded: true,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _filterEntriesByDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    print('Selected date: ${date.year}-${date.month}-${date.day}');
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MM月 dd EEE', 'zh_CN');
    final dateString = formatter.format(_selectedDate);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Text(
              '${_selectedDate.year}',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                color: Colors.grey[300],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: GestureDetector(
            onTap: () {
              _showCalendarModal();
            },
            child: Container(
              padding: const EdgeInsets.only(bottom: 16.0),
              alignment: Alignment.center,
              child: Container(
                width: 90,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            dateString.split(' ')[0], // Month
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            dateString.split(' ')[1], // Day
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            dateString.split(' ')[2], // Weekday
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Think Track',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendar'),
              onTap: () {
                // Calendar is accessible by tapping the date in the app bar
                // Just close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journal entries timeline
            Expanded(
              child: _getEntriesForSelectedDate().isEmpty
                  ? const Center(
                      child: Text(
                        'No journal entries yet for this date.\\nTap + to add your first entry!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _getEntriesForSelectedDate().length,
                      itemBuilder: (context, index) {
                        final entry = _getEntriesForSelectedDate()[index];
                        return JournalEntryCard(
                          entry: entry,
                          onTap: () => _editJournalEntry(entry),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addJournalEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}