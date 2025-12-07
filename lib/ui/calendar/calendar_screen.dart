import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/controllers/note_controller.dart';
import 'package:mindlog/features/notes/domain/entities/note.dart';
import 'package:mindlog/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:mindlog/features/notes/presentation/widgets/note_card.dart';
import 'package:mindlog/ui/design_system/design_system.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _currentDate;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  List<Note> _notesForSelectedDate = [];
  NoteController? _noteController;
  bool _isLoading = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<NoteEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    // Try to find the controller, and if not found, initialize it
    try {
      _noteController = Get.find<NoteController>();
    } catch (e) {
      // If the controller is not found, create and register it
      _noteController = Get.put(NoteController());
    }
    _currentDate = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedMonth = DateTime.now();
    // Load notes for the current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotesForDate(_currentDate!);
      _loadAllEvents();
    });
  }

  void _loadAllEvents() async {
    final notes = await _noteController!.getAllNotes();
    final events = <DateTime, List<NoteEvent>>{};

    for (final note in notes) {
      final date = DateTime(note.createTime.year, note.createTime.month, note.createTime.day);
      if (!events.containsKey(date)) {
        events[date] = [];
      }
      events[date]!.add(NoteEvent(note));
    }

    setState(() {
      _events = events;
    });
  }

  List<NoteEvent> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Future<void> _loadNotesForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get notes specifically for the selected date using the controller's method
      final notesForDate = await _noteController!.getNotesByDate(date);

      setState(() {
        _notesForSelectedDate = notesForDate;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMonthChanged(DateTime month) {
    setState(() {
      _selectedMonth = month;
      _focusedDay = month;
    });
  }

  void _showMonthPicker() async {
    final selectedMonth = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    
    if (selectedMonth != null) {
      _onMonthChanged(DateTime(selectedMonth.year, selectedMonth.month));
    }
  }

  // Helper function to check if two dates are in the same month
  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Year-Month Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedMonth.year}年${_selectedMonth.month}月',
                  style: TextStyle(
                    fontSize: AppFontSize.large,
                    fontWeight: AppFontWeight.semiBold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: _showMonthPicker,
                ),
              ],
            ),
          ),

          // Table Calendar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TableCalendar<NoteEvent>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_currentDate, day);
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                // 同步更新顶部显示的月份
                if (!_isSameMonth(_selectedMonth, focusedDay)) {
                  setState(() {
                    _selectedMonth = DateTime(focusedDay.year, focusedDay.month);
                  });
                }
              },
              eventLoader: _getEventsForDay,
              weekendDays: const [DateTime.sunday, DateTime.saturday],
              startingDayOfWeek: StartingDayOfWeek.sunday,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _currentDate = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadNotesForDate(selectedDay);
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: AppFontWeight.bold,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: AppFontWeight.normal,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronVisible: false,
                rightChevronVisible: false,
                headerMargin: EdgeInsets.zero,
                headerPadding: EdgeInsets.zero,
                decoration: BoxDecoration(),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: AppFontWeight.medium,
                ),
                weekendStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: AppFontWeight.medium,
                ),
                dowTextFormatter: (date, locale) {
                  final weekdays = ['日', '一', '二', '三', '四', '五', '六'];
                  return weekdays[date.weekday % 7];
                },
              ),
            ),
          ),

          // Selected date header
          if (_currentDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentDate!.year}-${_currentDate!.month}-${_currentDate!.day}',
                    style: TextStyle(
                      fontSize: AppFontSize.medium,
                      fontWeight: AppFontWeight.semiBold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${_notesForSelectedDate.length} 条笔记',
                    style: TextStyle(
                      fontSize: AppFontSize.small,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          // Notes list for selected date
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notesForSelectedDate.isEmpty
                ? Center(
                    child: Text(
                      '该日期没有笔记',
                      style: TextStyle(
                        fontSize: AppFontSize.large,
                        fontWeight: AppFontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadNotesForDate(_currentDate!);
                      return; // Required for the refresh indicator
                    },
                    child: ListView.builder(
                      padding: AppPadding.small,
                      itemCount: _notesForSelectedDate.length,
                      itemBuilder: (context, index) {
                        final note = _notesForSelectedDate[index];
                        return NoteCard(
                          note: note,
                          onEdit: () {
                            Get.to(
                              () => NoteDetailScreen(noteId: note.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

}

class NoteEvent {
  Note note;

  NoteEvent(this.note);
}