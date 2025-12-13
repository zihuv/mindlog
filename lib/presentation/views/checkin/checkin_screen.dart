import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindlog/presentation/controllers/check_in_controller.dart';
import 'package:mindlog/presentation/views/note/note_detail_screen.dart';
import 'package:mindlog/presentation/widgets/note/note_card.dart';
import 'package:mindlog/core/design_system/design_system.dart';
import '../notebooks/check_in_calendar_screen.dart'; // For CheckInEvent and CheckInEventType
import '../../widgets/common/custom_header_bar.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  late ScrollController _scrollController;
  late CheckInController _checkInController;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedMonth = DateTime.now();
    _scrollController = ScrollController();
    _checkInController = Get.find<CheckInController>();

    // Load notes for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInController.loadAllEvents();
      _checkInController.loadNotesForDate(DateTime.now());
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
        title: '打卡日历',
        showBackButton: true,
        actions: [
          // Add a floating action button with a check-in icon to make it more distinct
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.check_circle_outline),
              onPressed: () {
                // Create a new check-in note for today
                _checkInController.createNoteForDate(DateTime.now());
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _checkInController.loadNotesForDate(
            _checkInController.selectedDate.value,
          );
          _checkInController.loadAllEvents();
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
                    _checkInController.loadNotesForDate(selectedDay);
                  },
                  onDayLongPressed: (selectedDay, focusedDay) {
                    // Long press creates a new note for the specific date
                    _checkInController.createNoteForDate(selectedDay);
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    // Visual indicator for days with check-in events
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
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
                    // Different styling for check-in days
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

            // Selected date header with more check-in specific UI
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
                          final events = _getEventsForDay(selectedDate);

                          // Check if this day has notes with content (not just check-in markers)
                          final hasNoteWithContent = events.any(
                            (event) => event.type == CheckInEventType.noteWithContent
                          );

                          // Check if this day has any events at all
                          final hasAnyEvents = events.isNotEmpty;

                          return IconButton(
                            icon: Icon(
                              hasAnyEvents
                                  ? (hasNoteWithContent
                                      ? Icons.note_alt
                                      : Icons.check_circle)
                                  : Icons.radio_button_unchecked,
                              color: hasAnyEvents
                                  ? (hasNoteWithContent
                                      ? Theme.of(context).colorScheme.tertiary
                                      : Theme.of(context).colorScheme.primary)
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            tooltip: hasAnyEvents
                                ? (hasNoteWithContent ? 'Note with content' : 'Check-in only')
                                : 'No entry - tap to check in',
                            onPressed: () {
                              _checkInController.togglePunchForDate(
                                selectedDate,
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

            // Stats Summary Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Total check-ins
                      Column(
                        children: [
                          Obx(() => Text(
                            _checkInController.totalCheckIns.toString(),
                            style: TextStyle(
                              fontSize: AppFontSize.large,
                              fontWeight: AppFontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )),
                          Text(
                            '总打卡',
                            style: TextStyle(
                              fontSize: AppFontSize.small,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      // Current streak
                      Column(
                        children: [
                          Obx(() => Text(
                            _checkInController.currentStreak.toString(),
                            style: TextStyle(
                              fontSize: AppFontSize.large,
                              fontWeight: AppFontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )),
                          Text(
                            '当前连续',
                            style: TextStyle(
                              fontSize: AppFontSize.small,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      // Longest streak
                      Column(
                        children: [
                          Obx(() => Text(
                            _checkInController.longestStreak.toString(),
                            style: TextStyle(
                              fontSize: AppFontSize.large,
                              fontWeight: AppFontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )),
                          Text(
                            '最长连续',
                            style: TextStyle(
                              fontSize: AppFontSize.small,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '该日期没有记录',
                          style: TextStyle(
                            fontSize: AppFontSize.large,
                            fontWeight: AppFontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '长按日期创建打卡记录',
                          style: TextStyle(
                            fontSize: AppFontSize.small,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
      // Add a floating action button to create a new check-in
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _checkInController.createNoteForDate(_checkInController.selectedDate.value);
        },
        tooltip: 'Add Check-in',
        child: const Icon(Icons.add),
      ),
    );
  }
}
