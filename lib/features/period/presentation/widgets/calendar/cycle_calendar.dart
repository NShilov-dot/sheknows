import 'package:flutter/material.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/calendar_labels.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/calendar_legend.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/month_page.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/weekday_header.dart';

/// Interactive month calendar for the cycle.
///
/// * Months are swipeable via a [PageView] (36 months back, 24 forward).
/// * Logged period days render as a continuous rounded band across the week.
/// * The predicted next start is shown as a soft filled circle.
/// * Days with intimacy or other tracking show small dots underneath.
/// * Tapping a day reports it through [onDaySelected].
class CycleCalendar extends StatefulWidget {
  const CycleCalendar({
    super.key,
    required this.month,
    required this.logs,
    required this.dayLogs,
    required this.stats,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  final DateTime month;
  final List<PeriodLogEntity> logs;
  final List<DayLogEntity> dayLogs;
  final CycleStats? stats;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  State<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends State<CycleCalendar> {
  static const _pastMonths = 36;
  static const _futureMonths = 24;
  static const _totalPages = _pastMonths + _futureMonths + 1;

  late PageController _controller;
  late int _page;

  DateTime get _baseMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month - _pastMonths);
  }

  int _indexOf(DateTime month) {
    final base = _baseMonth;
    return (month.year - base.year) * 12 + month.month - base.month;
  }

  DateTime _monthAt(int page) {
    final base = _baseMonth;
    return DateTime(base.year, base.month + page);
  }

  @override
  void initState() {
    super.initState();
    _page = _indexOf(widget.month);
    _controller = PageController(initialPage: _page);
  }

  @override
  void didUpdateWidget(covariant CycleCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow external month changes (e.g. cubit reset after reload).
    final target = _indexOf(widget.month);
    if (target != _page) {
      _page = target;
      _controller.jumpToPage(target);
    }
  }

  void _animateTo(int page) {
    if (page < 0 || page >= _totalPages || page == _page) {
      return;
    }
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleMonth =
        DateTime(widget.month.year, widget.month.month);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous month',
              onPressed: _page > 0 ? () => _animateTo(_page - 1) : null,
            ),
            Text(
              '${kCalendarMonthNames[visibleMonth.month - 1]} '
              '${visibleMonth.year}',
              style: theme.textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next month',
              onPressed:
                  _page < _totalPages - 1 ? () => _animateTo(_page + 1) : null,
            ),
          ],
        ),
        // Height fits the worst case (6 week rows); cells are square because
        // each row divides the full width by 7.
        LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth / 7;
            return Column(
              children: [
                const SizedBox(
                  height: 24,
                  child: WeekdayHeader(),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: cellSize * 6,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _totalPages,
                    onPageChanged: (page) {
                      _page = page;
                      widget.onMonthChanged(_monthAt(page));
                    },
                    itemBuilder: (context, index) => MonthPage(
                      month: _monthAt(index),
                      logs: widget.logs,
                      dayLogs: widget.dayLogs,
                      stats: widget.stats,
                      onDaySelected: widget.onDaySelected,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        const CalendarLegend(),
      ],
    );
  }
}
