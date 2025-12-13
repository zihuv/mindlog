import 'package:get/get.dart';
import 'package:mindlog/data/models/note.dart';
import 'package:mindlog/data/services/note_service.dart';
import '../views/notebooks/check_in_calendar_screen.dart';

class CheckInController extends GetxController {
  final NoteService _noteService;

  CheckInController(this._noteService);

  // List of check-in events
  var checkInEvents = <DateTime, List<CheckInEvent>>{}.obs;

  // Currently selected date
  var selectedDate = DateTime.now().obs;

  // Notes for the selected date
  var notesForSelectedDate = <Note>[].obs;

  // Loading state
  var isLoading = false.obs;

  // Initialize controller
  @override
  void onInit() {
    super.onInit();
    loadAllEvents();
  }

  // Load all events for the calendar
  Future<void> loadAllEvents() async {
    try {
      isLoading.value = true;

      // Get all notes
      final notes = await _noteService.getAllNotes();

      final events = <DateTime, List<CheckInEvent>>{};

      for (final note in notes) {
        final date = DateTime(
          note.createTime.year,
          note.createTime.month,
          note.createTime.day,
        );
        if (!events.containsKey(date)) {
          events[date] = [];
        }
        events[date]!.add(CheckInEvent(note));
      }

      checkInEvents.value = events;
    } finally {
      isLoading.value = false;
    }
  }

  // Load all events for a specific notebook
  Future<void> loadAllEventsForNotebook(String notebookId) async {
    try {
      isLoading.value = true;

      // Get all notes for the notebook
      final notes = await _noteService.getNotesByNotebookId(notebookId);

      final events = <DateTime, List<CheckInEvent>>{};

      for (final note in notes) {
        final date = DateTime(
          note.createTime.year,
          note.createTime.month,
          note.createTime.day,
        );
        if (!events.containsKey(date)) {
          events[date] = [];
        }
        events[date]!.add(CheckInEvent(note));
      }

      checkInEvents.value = events;
    } finally {
      isLoading.value = false;
    }
  }

  // Load notes for a specific date
  Future<void> loadNotesForDate(DateTime date, {String? notebookId}) async {
    try {
      isLoading.value = true;

      // Get notes for the selected date
      final notes = notebookId != null
          ? await _noteService.getAllNotesByNotebookIdAndDate(notebookId, date)
          : await _noteService.getNotesByDate(date);

      notesForSelectedDate.assignAll(notes);
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle punch status for a specific date
  Future<void> togglePunchForDate(DateTime date, {String? notebookId}) async {
    // Check if there's already a note for this date
    final notesForDate = notebookId != null
        ? await _noteService.getNotesByNotebookIdAndDate(notebookId, date)
        : await _noteService.getNotesByDate(date);

    // Find a pure check-in note (one without substantial content)
    Note? checkInNote;
    List<Note> contentNotes = [];

    for (final note in notesForDate) {
      if (note.content.startsWith('打卡 - ') ||
          note.content.startsWith('Check-in - ') ||
          note.content.startsWith('打卡日志 - ')) {
        checkInNote = note;
      } else {
        // This is a note with actual content
        contentNotes.add(note);
      }
    }

    if (checkInNote != null) {
      // If there's a pure check-in note, delete it (punch off)
      await _noteService.deleteNote(checkInNote.id);
    } else if (contentNotes.isNotEmpty) {
      // If there are notes with content, toggle the first one's deletion status
      final note = contentNotes.first;
      if (note.isDeleted) {
        // Restore the note (punch on)
        await _noteService.updateNote(
          note.copyWith(isDeleted: false),
        );
      } else {
        // Delete the note (punch off) - soft delete
        await _noteService.deleteNote(note.id);
      }
    } else if (notesForDate.isEmpty) {
      // If no notes exist at all, create a new check-in (punch on)
      await _noteService.createNote(
        content: '打卡 - ${date.year}-${date.month}-${date.day}',
        notebookId: notebookId,
        createTime: DateTime(date.year, date.month, date.day, 0, 0, 0),
      );
    }

    // Refresh events
    await loadAllEvents();
    await loadNotesForDate(date, notebookId: notebookId);
  }

  // Create a note for a specific date
  Future<void> createNoteForDate(DateTime date, {String? notebookId}) async {
    await _noteService.createNote(
      content: '打卡日志 - ${date.year}-${date.month}-${date.day}',
      notebookId: notebookId,
      createTime: DateTime(date.year, date.month, date.day, 0, 0, 0),
    );

    // Refresh events
    await loadAllEvents();
    await loadNotesForDate(date, notebookId: notebookId);
  }

  // Get events for a specific day
  List<CheckInEvent> getEventsForDay(DateTime day) {
    return checkInEvents[day] ?? [];
  }

  // Update selected date
  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  // Calculate total check-ins
  int get totalCheckIns {
    return checkInEvents.values.fold(0, (sum, events) => sum + events.length);
  }

  // Calculate current streak
  int get currentStreak {
    // Placeholder implementation - in a real app, this would calculate based on consecutive days
    // For now, returning a sample value
    return _calculateCurrentStreak();
  }

  // Calculate longest streak
  int get longestStreak {
    // Placeholder implementation - in a real app, this would calculate based on historical data
    return _calculateLongestStreak();
  }

  int _calculateCurrentStreak() {
    if (checkInEvents.isEmpty) return 0;

    // Get all the dates that have check-ins and sort them
    List<DateTime> checkInDates = checkInEvents.keys.toList()..sort();

    if (checkInDates.isEmpty) return 0;

    // Start from today and count backwards
    DateTime currentDate = DateTime.now();
    // Normalize to just the date part (no time)
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    int streak = 0;

    // If today doesn't have a check-in, we need to go back until we find the last check-in date
    DateTime possibleDate = currentDate;
    while (possibleDate.isAfter(checkInDates.first) &&
           !checkInEvents.containsKey(DateTime(possibleDate.year, possibleDate.month, possibleDate.day))) {
      possibleDate = DateTime(possibleDate.year, possibleDate.month, possibleDate.day - 1);
    }

    // If we reached a date before our first check-in and found no check-ins, streak is 0
    if (!checkInEvents.containsKey(DateTime(possibleDate.year, possibleDate.month, possibleDate.day))) {
      return 0;
    }

    // Now count backwards from the most recent check-in date
    DateTime currentCheckDate = DateTime(possibleDate.year, possibleDate.month, possibleDate.day);
    while (checkInEvents.containsKey(currentCheckDate)) {
      streak++;
      currentCheckDate = DateTime(currentCheckDate.year, currentCheckDate.month, currentCheckDate.day - 1);
    }

    return streak;
  }

  int _calculateLongestStreak() {
    if (checkInEvents.isEmpty) return 0;

    List<DateTime> checkInDates = checkInEvents.keys.toList()..sort();
    if (checkInDates.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? previousDate;

    for (DateTime date in checkInDates) {
      if (previousDate == null) {
        // First date
        currentStreak = 1;
      } else {
        // Calculate the difference in days
        int daysDiff = _daysBetween(previousDate, date);

        if (daysDiff == 1) {
          // Consecutive day
          currentStreak++;
        } else if (daysDiff == 0) {
          // Same day (shouldn't happen since we're iterating through a set of dates)
          continue;
        } else {
          // Non-consecutive day: reset streak and record max if needed
          maxStreak = (maxStreak > currentStreak) ? maxStreak : currentStreak;
          currentStreak = 1;
        }
      }
      previousDate = date;
    }

    // Don't forget the last streak
    maxStreak = (maxStreak > currentStreak) ? maxStreak : currentStreak;

    return maxStreak;
  }

  // Helper function to calculate days between two dates
  int _daysBetween(DateTime from, DateTime to) {
    var fromWithoutTime = DateTime(from.year, from.month, from.day);
    var toWithoutTime = DateTime(to.year, to.month, to.day);
    return (toWithoutTime.difference(fromWithoutTime).inDays).abs();
  }
}


