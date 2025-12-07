import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/features/notes/data/note_service.dart';
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
  bool _isLoading = false;
  Map<DateTime, List<NoteEvent>> _events = {};
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedMonth = DateTime.now();
    _scrollController = ScrollController();
    // Load notes for the current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotesForDate(_currentDate!);
      _loadAllEvents();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadAllEvents() async {
    final notes = await Get.find<NoteService>().getAllNotes();
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
      // Get notes specifically for the selected date using the service directly
      final notesForDate = await Get.find<NoteService>().getNotesByDate(date);

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
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadNotesForDate(_currentDate!);
          _loadAllEvents();
          return; // Required for the refresh indicator
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Year-Month Selector
            SliverToBoxAdapter(
              child: Padding(
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
                      ),
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: _showMonthPicker,
                    ),
                  ],
                ),
              ),
            ),

            // Table Calendar
            SliverToBoxAdapter(
              child: Listener(
                onPointerMove: (event) {
                  // 捕获垂直滑动
                  final delta = event.delta.dy;
                  if (delta != 0) {
                    // 模拟滚动
                    _scrollController.jumpTo(
                      _scrollController.offset - delta,
                    );
                  }
                },
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TableCalendar<NoteEvent>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_currentDate, day);
                  },
                  calendarFormat: CalendarFormat.month,
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
              ),
            ),

            // Selected date header
            if (_currentDate != null)
              SliverToBoxAdapter(
                child: Padding(
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
              ),

            // Notes list for selected date
            if (_isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_notesForSelectedDate.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      '该日期没有笔记',
                      style: TextStyle(
                        fontSize: AppFontSize.large,
                        fontWeight: AppFontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: _notesForSelectedDate.length,
                  (context, index) {
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
          ],
        ),
      ),
    );
  }

}

class NoteEvent {
  Note note;

  NoteEvent(this.note);
}