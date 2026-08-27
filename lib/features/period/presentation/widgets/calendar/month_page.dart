import 'package:flutter/material.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/day_cell.dart';

/// One month of the calendar grid: up to six Monday-first week rows.
class MonthPage extends StatelessWidget {
  const MonthPage({
    super.key,
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (var row = 0; row * 7 < totalCells; row++)
          Row(
            children: [
              for (final day in _weekDays(row, leadingBlanks, totalCells))
                if (day == null)
                  const Expanded(child: SizedBox())
                else
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: DayCell(
                        day: day,
                        band: _bandFor(day),
                        marks: _marksFor(day),
                        isPredictedStart:
                            _isSameDay(day, stats?.nextPredictedStart),
                        isToday: _isSameDay(day, DateTime.now()),
                        onTap: () => onDaySelected(day),
                      ),
                    ),
                  ),
            ],
          ),
      ],
    );
  }

  /// The seven day slots of week [row]; `null` where the cell is blank.
  List<DateTime?> _weekDays(int row, int leadingBlanks, int totalCells) => [
        for (var col = 0; col < 7; col++)
          if (row * 7 + col >= totalCells || row * 7 + col < leadingBlanks)
            null
          else
            DateTime(month.year, month.month, row * 7 + col - leadingBlanks + 1),
      ];

  /// Finds the covering log and whether the band continues into the
  /// neighbouring cells of the same log.
  BandInfo? _bandFor(DateTime day) {
    for (final log in logs) {
      if (!log.coversDay(day)) {
        continue;
      }
      return BandInfo(
        extendsLeft: log.coversDay(_shift(day, -1)),
        extendsRight: log.coversDay(_shift(day, 1)),
      );
    }
    return null;
  }

  /// The tracking markers (intimacy / other) to show under [day], if any.
  DayMarks _marksFor(DateTime day) {
    for (final log in dayLogs) {
      if (!log.isOnDay(day)) {
        continue;
      }
      return DayMarks(
        intimacy: log.sexualActivity != null,
        other: log.notes != null && log.notes!.trim().isNotEmpty,
      );
    }
    return const DayMarks(intimacy: false, other: false);
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

/// Whether a logged-period band continues into the neighbouring day cells.
class BandInfo {
  const BandInfo({required this.extendsLeft, required this.extendsRight});

  final bool extendsLeft;
  final bool extendsRight;
}

/// Tracking markers shown under a day number.
class DayMarks {
  const DayMarks({required this.intimacy, required this.other});

  final bool intimacy;
  final bool other;

  bool get hasAny => intimacy || other;
}
