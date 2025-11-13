import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart'; // Required for PointerDeviceKind
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../domain/entities/journal_entry.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/journal_entry_screen.dart';
import 'package:mindlog/core/storage/storage_service.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../memos/presentation/pages/memos_page.dart';

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



  void _sortJournalEntries() {
    _journalEntries.sort(
      (a, b) => a.dateTime.compareTo(b.dateTime),
    ); // Sort in ascending order (oldest first)
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
              dateTime:
                  entryDate, // Use the date from the screen, which preserves original time in edit mode
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
                      onDateSelected: (selectedDate) async {
                        await _filterEntriesByDate(selectedDate);
                        // Close the modal after the animation completes
                        Navigator.pop(context);
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

  Future<void> _filterEntriesByDate(DateTime date) async {
    // Calculate the page index for the selected date based on the initial date
    // Normalize both dates to start of day to avoid timezone/time component issues
    DateTime normalizedSelectedDate = DateTime(date.year, date.month, date.day);
    DateTime normalizedInitialDate = DateTime(
      _initialDate.year,
      _initialDate.month,
      _initialDate.day,
    );

    int daysDifference = normalizedSelectedDate
        .difference(normalizedInitialDate)
        .inDays;
    int pageIndex = _getInitialPageIndex() + daysDifference;

    setState(() {
      _selectedDate = normalizedSelectedDate;
    });

    // Animate to the correct page in the PageView
    await _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    print(
      'Selected date: ${normalizedSelectedDate.year}-${normalizedSelectedDate.month}-${normalizedSelectedDate.day}, pageIndex: $pageIndex',
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
    });
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
                : ScrollConfiguration(
                    // Allow scrolling for the content within the page
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind
                            .trackpad, // Add trackpad support for Mac
                        PointerDeviceKind.stylus,
                        PointerDeviceKind.unknown,
                      },
                    ),
                    child: NotificationListener<ScrollEndNotification>(
                      onNotification: (notification) {
                        if (notification.dragDetails != null) {
                          // This is a direct drag, not a velocity-driven scroll
                          return false;
                        }
                        // Handle fling gestures
                        return false;
                      },
                      child: ListView.builder(
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

    return PopScope(
      // Add PopScope to control back button behavior (replaces deprecated WillPopScope)
      canPop: false, // Don't allow pop
      child: Scaffold(
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
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'MindLog',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Journal'),
                onTap: () {
                  // Already on journal page, just close drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Memos'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MemosPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
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
              PointerDeviceKind.trackpad, // Add trackpad support for Mac
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

              // Use Listener for trackpad/mouse wheel events, separate from PageView gestures
              return Listener(
                onPointerSignal: (PointerSignalEvent event) {
                  if (event is PointerScrollEvent) {
                    // Handle trackpad/mouse wheel scroll events for date navigation
                    // Only respond to horizontal scrolling (trackpad swipe)
                    if (event.scrollDelta.dx != 0 &&
                        event.scrollDelta.dy == 0) {
                      // Increase the sensitivity threshold since trackpad swipes are usually small
                      if (event.scrollDelta.dx.abs() > 10) {
                        // Only respond to significant swipes
                        if (event.scrollDelta.dx > 0) {
                          // Swipe right on trackpad - go to next day
                          _goToNextDay();
                        } else if (event.scrollDelta.dx < 0) {
                          // Swipe left on trackpad - go to previous day
                          _goToPreviousDay();
                        }
                      }
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
      ),
    );
  }
}
