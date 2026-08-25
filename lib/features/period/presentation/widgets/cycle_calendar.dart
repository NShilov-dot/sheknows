import 'package:flutter/material.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';

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
              '${_monthNames[visibleMonth.month - 1]} ${visibleMonth.year}',
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
                  child: _WeekdayHeader(),
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
                    itemBuilder: (context, index) => _MonthPage(
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
        const _CalendarLegend(),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (final name in _weekdayNames)
          Expanded(
            child: Center(
              child: Text(
                name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _weekdayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class _MonthPage extends StatelessWidget {
  const _MonthPage({
    required this.month,
    required this.logs,
    required this.dayLogs,
    required this.stats,
    required this.onDaySelected,
  });

  final DateTime month;
  final List<PeriodLogEntity> logs;
  final List<DayLogEntity> dayLogs;
  final CycleStats? stats;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final leadingBlanks = (firstDay.weekday + 6) % 7; // Monday-first.
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = leadingBlanks + daysInMonth;

    Widget buildCell(int index) {
      if (index < leadingBlanks) {
        return const Expanded(child: SizedBox());
      }
      final day = DateTime(month.year, month.month, index - leadingBlanks + 1);
      return Expanded(
        child: AspectRatio(
          aspectRatio: 1,
          child: _DayCell(
            day: day,
            band: _bandFor(day),
            marks: _marksFor(day),
            isPredictedStart: _isSameDay(day, stats?.nextPredictedStart),
            isToday: _isSameDay(day, DateTime.now()),
            onTap: () => onDaySelected(day),
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (var row = 0; row * 7 < totalCells; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                if (row * 7 + col >= totalCells)
                  const Expanded(child: SizedBox())
                else
                  buildCell(row * 7 + col),
            ],
          ),
      ],
    );
  }

  /// Finds the covering log and whether the band continues into the
  /// neighbouring cells of the same log.
  _BandInfo? _bandFor(DateTime day) {
    for (final log in logs) {
      if (!log.coversDay(day)) {
        continue;
      }
      return _BandInfo(
        extendsLeft: log.coversDay(_shift(day, -1)),
        extendsRight: log.coversDay(_shift(day, 1)),
      );
    }
    return null;
  }

  /// The tracking markers (intimacy / other) to show under [day], if any.
  _DayMarks _marksFor(DateTime day) {
    for (final log in dayLogs) {
      if (!log.isOnDay(day)) {
        continue;
      }
      return _DayMarks(
        intimacy: log.sexualActivity != null,
        other: log.symptoms.isNotEmpty ||
            log.mood != null ||
            (log.notes != null && log.notes!.trim().isNotEmpty),
      );
    }
    return const _DayMarks(intimacy: false, other: false);
  }

  static DateTime _shift(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);

  static bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _BandInfo {
  const _BandInfo({required this.extendsLeft, required this.extendsRight});

  final bool extendsLeft;
  final bool extendsRight;
}

class _DayMarks {
  const _DayMarks({required this.intimacy, required this.other});

  final bool intimacy;
  final bool other;

  bool get hasAny => intimacy || other;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.band,
    required this.marks,
    required this.isPredictedStart,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final _BandInfo? band;
  final _DayMarks marks;
  final bool isPredictedStart;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Compute "future" against a fresh clock each build so shading stays correct
    // if the app is left open across midnight (isToday uses DateTime.now() too).
    final isFuture = day.isAfter(DateTime.now());
    final hasBand = band != null;
    final isOnBand = hasBand && !isFuture;

    var labelColor = isFuture
        ? scheme.onSurface.withValues(alpha: 0.35)
        : scheme.onSurface;
    if (isOnBand) {
      labelColor = scheme.onSecondary;
    } else if (isPredictedStart) {
      labelColor = scheme.secondary;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Continuous band behind logged period days.
          if (hasBand)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(
                      alpha: isFuture ? 0.25 : 0.9,
                    ),
                    borderRadius: BorderRadius.horizontal(
                      left: band!.extendsLeft
                          ? Radius.zero
                          : const Radius.circular(20),
                      right: band!.extendsRight
                          ? Radius.zero
                          : const Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ),

          // Predicted next period start.
          if (!hasBand && isPredictedStart)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.secondary.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),

          // Today ring.
          if (isToday)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOnBand ? scheme.onSecondary : scheme.outline,
                  width: 1.5,
                ),
              ),
            ),

          Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: labelColor,
              fontWeight: isToday || isPredictedStart
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),

          // Tracking dots (intimacy / other) under the day number.
          if (marks.hasAny)
            Positioned(
              bottom: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (marks.intimacy)
                    _Dot(color: isOnBand ? scheme.onSecondary : scheme.primary),
                  if (marks.intimacy && marks.other) const SizedBox(width: 3),
                  if (marks.other)
                    _Dot(color: isOnBand ? scheme.onSecondary : scheme.tertiary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 4,
      children: [
        _legendItem(
          Container(
            width: 18,
            height: 10,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.horizontal(
                left: const Radius.circular(6),
                right: Radius.zero,
              ),
            ),
          ),
          'Logged',
          theme,
        ),
        _legendItem(
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.secondary.withValues(alpha: 0.15),
            ),
          ),
          'Predicted',
          theme,
        ),
        _legendItem(
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outline, width: 1.5),
            ),
          ),
          'Today',
          theme,
        ),
        _legendItem(
          _Dot(color: scheme.primary),
          'Intimacy',
          theme,
        ),
        _legendItem(
          _Dot(color: scheme.tertiary),
          'Symptoms/notes',
          theme,
        ),
      ],
    );
  }

  Widget _legendItem(Widget marker, String label, ThemeData theme) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          marker,
          const SizedBox(width: 5),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      );
}
