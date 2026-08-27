import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/calendar_legend.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/month_page.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/weekday_header.dart';
import 'package:sheknows/l10n/app_localizations.dart';

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

  /// Frozen at construction: recomputing it would shift the page<->month
  /// mapping under the PageView if the app is left open across a month change.
  late final DateTime _baseMonth;

  /// Page index for [month], clamped to the available window: a stale or
  /// restored month outside it must not produce an out-of-range page.
  int _indexOf(DateTime month) {
    final base = _baseMonth;
    final index = (month.year - base.year) * 12 + month.month - base.month;
    return index.clamp(0, _totalPages - 1);
  }

  DateTime _monthAt(int page) {
    final base = _baseMonth;
    return DateTime(base.year, base.month + page);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _baseMonth = DateTime(now.year, now.month - _pastMonths);
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
    final l10n = AppLocalizations.of(context);
    final visibleMonth =
        DateTime(widget.month.year, widget.month.month);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: l10n.cycleCalendarPreviousMonth,
              onPressed: _page > 0 ? () => _animateTo(_page - 1) : null,
            ),
            Flexible(
              child: Text(
                DateFormat.yMMMM(Localizations.localeOf(context).toString())
                    .format(visibleMonth),
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: l10n.cycleCalendarNextMonth,
              onPressed:
                  _page < _totalPages - 1 ? () => _animateTo(_page + 1) : null,
            ),
          ],
        ),
        // Height fits the worst case (6 week rows); cells are square because
        // each row divides the grid width by 7. The cell is capped so the grid
        // stays phone-sized (and centred) on tablets and in landscape.
        LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = math.min(constraints.maxWidth / 7, 56.0);
            return Center(
              child: SizedBox(
                width: cellSize * 7,
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 24),
                      child: const WeekdayHeader(),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: cellSize * 6,
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _totalPages,
                        onPageChanged: (page) {
                          setState(() => _page = page);
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
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        const CalendarLegend(),
      ],
    );
  }
}
