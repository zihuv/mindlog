import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isExpanded;

  const CalendarWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update display month when the selected date changes significantly
    if (widget.selectedDate.year != oldWidget.selectedDate.year ||
        widget.selectedDate.month != oldWidget.selectedDate.month) {
      _displayMonth = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        1,
      );
    }
  }

  void _previousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 180, // Reduced height for smaller calendar
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        children: [
          // Month header with navigation arrows
          Container(
            margin: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: _previousMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                Text(
                  '${_displayMonth.year}年 ${_displayMonth.month}月',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: _nextMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
          // Weekday headers
          Container(
            margin: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['日', '一', '二', '三', '四', '五', '六']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // Calendar grid
          Expanded(child: _buildCalendarGrid(context)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime firstDayOfDisplayMonth = DateTime(
      _displayMonth.year,
      _displayMonth.month,
      1,
    );

    // Find the starting day of the week for the first day of the month
    int startDayOfWeek =
        firstDayOfDisplayMonth.weekday % 7; // Sunday is 0, Monday is 1, etc.

    // Create a list of days to show in the calendar grid (42 cells = 6 rows * 7 days)
    List<DateTime?> days = List.generate(42, (index) => null);

    // Fill in the days of the month
    for (
      int i = 0;
      i < DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
      i++
    ) {
      days[startDayOfWeek + i] = DateTime(
        _displayMonth.year,
        _displayMonth.month,
        i + 1,
      );
    }

    // Add days from the previous month to fill the first week
    if (startDayOfWeek > 0) {
      DateTime previousMonth = DateTime(
        _displayMonth.year,
        _displayMonth.month - 1,
        0,
      );
      for (int i = 0; i < startDayOfWeek; i++) {
        int day = previousMonth.day - startDayOfWeek + i + 1;
        days[i] = DateTime(previousMonth.year, previousMonth.month, day);
      }
    }

    // Add days from the next month to fill the last week
    int lastDayIndex = days.indexWhere((day) => day == null);
    if (lastDayIndex == -1) {
      lastDayIndex = 42; // If no nulls, all 42 slots are filled
    }
    DateTime nextMonth = DateTime(
      _displayMonth.year,
      _displayMonth.month + 1,
      1,
    );
    for (int i = lastDayIndex; i < 42; i++) {
      int day = i - lastDayIndex + 1;
      days[i] = DateTime(nextMonth.year, nextMonth.month, day);
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        DateTime? day = days[index];
        if (day == null) return const SizedBox.shrink();

        bool isDisplayMonth =
            day.month == _displayMonth.month && day.year == _displayMonth.year;
        bool isSelected =
            widget.selectedDate.day == day.day &&
            widget.selectedDate.month == day.month &&
            widget.selectedDate.year == day.year;
        bool isToday =
            day.day == today.day &&
            day.month == today.month &&
            day.year == today.year;

        return GestureDetector(
          onTap: () => widget.onDateSelected(day),
          child: Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isToday
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isSelected || isToday
                  ? Border.all(
                      color: Theme.of(context).primaryColor,
                      width: isSelected ? 2.0 : 1.0,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? Theme.of(context).primaryColor
                      : isDisplayMonth
                      ? Colors.black87
                      : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
