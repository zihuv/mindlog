import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/presentation/controllers/check_in_controller.dart';
import 'package:mindlog/data/models/note.dart';
import 'package:mindlog/presentation/views/note/note_detail_screen.dart';
import 'package:mindlog/presentation/widgets/note/note_card.dart';
import 'package:mindlog/core/design_system/design_system.dart';
import 'package:mindlog/presentation/widgets/common/custom_header_bar.dart';

class CheckInCalendarScreen extends StatefulWidget {
  final String? notebookId;

  const CheckInCalendarScreen({super.key, this.notebookId});

  @override
  State<CheckInCalendarScreen> createState() => _CheckInCalendarScreenState();
}

class _CheckInCalendarScreenState extends State<CheckInCalendarScreen> {
  DateTime? _currentDate;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  late ScrollController _scrollController;
  late CheckInController _checkInController;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedMonth = DateTime.now();
    _scrollController = ScrollController();
    _checkInController = Get.find<CheckInController>();

    // Load notes for the current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.notebookId != null) {
        _checkInController.loadAllEventsForNotebook(widget.notebookId!);
      } else {
        _checkInController.loadAllEvents();
      }
      _checkInController.loadNotesForDate(
        _currentDate!,
        notebookId: widget.notebookId,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<CheckInEvent> _getEventsForDay(DateTime day) {
    return _checkInController.getEventsForDay(day);
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
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
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
      appBar: CustomHeaderBar(
        title: widget.notebookId != null ? 'Notebook Check-in' : 'Check-in Calendar',
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _checkInController.loadNotesForDate(
            _checkInController.selectedDate.value,
            notebookId: widget.notebookId,
          );
          if (widget.notebookId != null) {
            _checkInController.loadAllEventsForNotebook(widget.notebookId!);
          } else {
            _checkInController.loadAllEvents();
          }
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
                      icon: Icon(Icons.calendar_month),
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: _showMonthPicker,
                    ),
                  ],
                ),
              ),
            ),

            // Table Calendar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TableCalendar<CheckInEvent>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(
                      _checkInController.selectedDate.value,
                      day,
                    );
                  },
                  calendarFormat: CalendarFormat.month,
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    // 同步更新顶部显示的月份
                    if (!_isSameMonth(_selectedMonth, focusedDay)) {
                      setState(() {
                        _selectedMonth = DateTime(
                          focusedDay.year,
                          focusedDay.month,
                        );
                      });
                    }
                  },
                  eventLoader: _getEventsForDay,
                  weekendDays: const [DateTime.sunday, DateTime.saturday],
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  onDaySelected: (selectedDay, focusedDay) {
                    _checkInController.updateSelectedDate(selectedDay);
                    _checkInController.loadNotesForDate(
                      selectedDay,
                      notebookId: widget.notebookId,
                    );
                  },
                  onDayLongPressed: (selectedDay, focusedDay) {
                    // Long press creates a new note for the specific date
                    _checkInController.createNoteForDate(
                      selectedDay,
                      notebookId: widget.notebookId,
                    );
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
                    // Different style for punched days
                    // This is handled by the eventLoader and markers
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

            // Selected date header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final selectedDate =
                          _checkInController.selectedDate.value;
                      return Text(
                        '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                        style: TextStyle(
                          fontSize: AppFontSize.medium,
                          fontWeight: AppFontWeight.semiBold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      );
                    }),
                    Row(
                      children: [
                        Obx(() {
                          final noteCount =
                              _checkInController.notesForSelectedDate.length;
                          return Text(
                            '$noteCount 条记录',
                            style: TextStyle(
                              fontSize: AppFontSize.small,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          );
                        }),
                        // Punch button - toggles punch status
                        Obx(() {
                          final selectedDate =
                              _checkInController.selectedDate.value;
                          final hasEvents = _getEventsForDay(
                            selectedDate,
                          ).isNotEmpty;
                          return IconButton(
                            icon: Icon(
                              hasEvents
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: hasEvents
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              _checkInController.togglePunchForDate(
                                selectedDate,
                                notebookId: widget.notebookId,
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Notes list for selected date
            Obx(() {
              if (_checkInController.isLoading.value) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              } else if (_checkInController.notesForSelectedDate.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '该日期没有记录',
                        style: TextStyle(
                          fontSize: AppFontSize.large,
                          fontWeight: AppFontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: _checkInController.notesForSelectedDate.length,
                    (context, index) {
                      final note =
                          _checkInController.notesForSelectedDate[index];
                      return NoteCard(
                        note: note,
                        onEdit: () {
                          Get.to(() => NoteDetailScreen(noteId: note.id));
                        },
                      );
                    },
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}

enum CheckInEventType {
  checkInOnly,  // Pure check-in, no content
  noteWithContent,  // Note with actual content
}

class CheckInEvent {
  Note note;
  CheckInEventType type;

  CheckInEvent(this.note) : type = _determineEventType(note);

  static CheckInEventType _determineEventType(Note note) {
    // Check if the note is just a check-in marker (like "打卡 - 2023-12-01")
    if (note.content.startsWith('打卡 - ') ||
        note.content.startsWith('Check-in - ') ||
        note.content.startsWith('打卡日志 - ')) {
      return CheckInEventType.checkInOnly;
    } else {
      // Note has actual content beyond just the check-in marker
      return CheckInEventType.noteWithContent;
    }
  }
}
