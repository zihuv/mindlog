import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart'; // Required for PointerDeviceKind
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../domain/entities/journal_entry.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/journal_entry_screen.dart';
import 'package:think_tract_flutter/core/storage/storage_service.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<JournalEntry> _journalEntries = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _initialDate = DateTime.now(); // Keep track of the initial date
  final PageController _pageController = PageController();
  int _currentPageIndex =
      0; // Track the current date index relative to the initial date

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('zh_CN', null);
    // Set _initialDate to today's date once at initialization
    _initialDate = DateTime.now();
    _selectedDate = _initialDate;

    // Initialize page controller to the middle (today's index) to allow swiping both ways
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(
        _getInitialPageIndex(),
      ); // Start at the calculated initial page
    });

    _loadJournalEntries();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadJournalEntries() async {
    try {
      _journalEntries = await StorageService.instance.getAllJournalEntries();
      _sortJournalEntries();
      setState(() {});
    } catch (e) {
      print('Error loading journal entries: $e');
    }
  }

  void _addJournalEntry() async {
    // Navigate to the journal entry screen and pass the callback to add entry
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryScreen(
          onSave: (content, mood, entryDate) async {
            final newEntry = JournalEntry(
              id: DateTime.now().millisecondsSinceEpoch,
              content: content,
              dateTime: entryDate, // Use the entry date provided by the screen
              mood: mood,
            );

            await StorageService.instance.saveJournalEntry(newEntry);

            setState(() {
              _journalEntries.insert(0, newEntry);
              _sortJournalEntries();
            });
          },
          initialDate: _selectedDate, // Pass the selected date
          isEdit: false, // This is a new entry, not an edit
        ),
      ),
    );
  }

  void _editJournalEntry(JournalEntry entry) async {
    // Navigate to the journal entry screen in edit mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryScreen(
          onSave: (content, mood, entryDate) async {
            final updatedEntry = JournalEntry(
              id: entry.id,
              content: content,
              dateTime: entry.dateTime, // Keep the original time
              mood: mood,
            );

            await StorageService.instance.updateJournalEntry(updatedEntry);

            setState(() {
              // Find the index of the entry to edit
              int index = _journalEntries.indexWhere((e) => e.id == entry.id);
              if (index != -1) {
                _journalEntries[index] = updatedEntry;
              }
            });
          },
          initialContent: entry.content,
          initialMood: entry.mood,
          initialDate: entry.dateTime, // Pass the original date of the entry
          isEdit: true, // This is an edit operation
        ),
      ),
    );
  }

  void _sortJournalEntries() {
    _journalEntries.sort(
      (a, b) => a.dateTime.compareTo(b.dateTime),
    ); // Sort in ascending order (oldest first)
  }

  List<JournalEntry> _getEntriesForSelectedDate() {
    // Return entries for the selected date
    return _journalEntries.where((entry) {
      return entry.dateTime.year == _selectedDate.year &&
          entry.dateTime.month == _selectedDate.month &&
          entry.dateTime.day == _selectedDate.day;
    }).toList();
  }

  List<JournalEntry> _getEntriesForDate(DateTime date) {
    // Return entries for a specific date
    return _journalEntries.where((entry) {
      return entry.dateTime.year == date.year &&
          entry.dateTime.month == date.month &&
          entry.dateTime.day == date.day;
    }).toList();
  }

  void _editJournalEntryWithDate(JournalEntry entry, DateTime date) {
    // Navigate to the journal entry screen in edit mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryScreen(
          onSave: (content, mood, entryDate) async {
            final updatedEntry = JournalEntry(
              id: entry.id,
              content: content,
              dateTime: entry.dateTime, // Keep the original time
              mood: mood,
            );

            await StorageService.instance.updateJournalEntry(updatedEntry);

            setState(() {
              // Find the index of the entry to edit
              int index = _journalEntries.indexWhere((e) => e.id == entry.id);
              if (index != -1) {
                _journalEntries[index] = updatedEntry;
              }
            });
          },
          initialContent: entry.content,
          initialMood: entry.mood,
          initialDate: entry.dateTime, // Pass the original date of the entry
          isEdit: true, // This is an edit operation
        ),
      ),
    );
  }

  void _showCalendarModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to expand to full height if needed
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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
                        Navigator.pop(
                          context,
                        ); // Close the modal after selection
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
    // Calculate the page index for the selected date based on the initial date
    int daysDifference = date.difference(_initialDate).inDays;
    int pageIndex = _getInitialPageIndex() + daysDifference;

    setState(() {
      _selectedDate = date;
    });

    // Animate to the correct page in the PageView
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    print(
      'Selected date: ${date.year}-${date.month}-${date.day}, pageIndex: $pageIndex',
    );
  }

  Widget _buildJournalContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Journal entries timeline
          Expanded(
            child: _getEntriesForSelectedDate().isEmpty
                ? const Center(
                    child: Text(
                      'No journal entries yet for this date.\nTap + to add your first entry!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
    );
  }

  int _getInitialPageIndex() {
    // Return a large number so users can swipe in both directions
    // We'll use this as the starting point for negative and positive offsets
    return 500000; // A large number to allow for many years of swiping in both directions
  }

  void _handlePageChanged(int index) {
    // Calculate the date for this page based on the initial date and index
    int offset =
        index - _getInitialPageIndex(); // Calculate offset from initial page
    DateTime newDate = DateTime(
      _initialDate.year,
      _initialDate.month,
      _initialDate.day + offset,
    );

    // Update selected date
    setState(() {
      _selectedDate = newDate;
      _currentPageIndex = offset; // Store relative index
    });

    // Reload entries for the new date
    _loadJournalEntries();
  }

  void _goToPreviousDay() {
    // Navigate to the previous day by going to the previous page in the PageView
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextDay() {
    // Navigate to the next day by going to the next page in the PageView
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildJournalContentForDate(DateTime date) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Journal entries timeline
          Expanded(
            child: _getEntriesForDate(date).isEmpty
                ? const Center(
                    child: Text(
                      'No journal entries yet for this date.\nTap + to add your first entry!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _getEntriesForDate(date).length,
                    itemBuilder: (context, index) {
                      final entry = _getEntriesForDate(date)[index];
                      return JournalEntryCard(
                        entry: entry,
                        onTap: () => _editJournalEntryWithDate(entry, date),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
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
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Date display with gesture detection (balanced compactness and readability)
                GestureDetector(
                  onTap: () {
                    _showCalendarModal();
                  },
                  child: Container(
                    width: 85,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 6.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dateString.split(' ')[0], // Month
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            dateString.split(' ')[1], // Day
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dateString.split(' ')[2], // Weekday
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                'Think Track',
                style: TextStyle(color: Colors.white, fontSize: 24),
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
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown,
          },
        ),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: _handlePageChanged,
          itemCount: null, // Infinite pages
          itemBuilder: (context, index) {
            // Calculate the date for this page based on the initial date and index
            // We'll use a large starting index and calculate the offset
            // For our purposes, we'll treat index 0 as the current date
            DateTime pageDate = DateTime(
              _initialDate.year,
              _initialDate.month,
              _initialDate.day + (index - _getInitialPageIndex()),
            );

            return Listener(
              onPointerSignal: (PointerSignalEvent event) {
                if (event is PointerScrollEvent) {
                  // Handle touchpad scroll events
                  double delta = event.scrollDelta.dx != 0
                      ? event.scrollDelta.dx
                      : event.scrollDelta.dy;

                  if (delta > 0) {
                    // Scroll right (user wants to go to next day)
                    _goToNextDay();
                  } else if (delta < 0) {
                    // Scroll left (user wants to go to previous day)
                    _goToPreviousDay();
                  }
                }
              },
              child: _buildJournalContentForDate(pageDate),
            );
          },
          // Add page snapping for better UX
          pageSnapping: true,
          // Use BouncingScrollPhysics for smoother interaction
          physics: const BouncingScrollPhysics(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addJournalEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
