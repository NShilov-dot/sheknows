import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';

/// Human-readable description of what [day] means for the cycle: which day of
/// a logged period it is, whether it is the predicted start, the cycle day, or
/// that nothing is known about it.
///
/// [today] is a parameter rather than a `DateTime.now()` call so that the
/// caller and this function cannot disagree across a midnight boundary.
String dayStatusLabel({
  required DateTime day,
  required DateTime today,
  required List<PeriodLogEntity> logs,
  required CycleStats stats,
}) {
  final isFuture = day.isAfter(today);
  final covering = logs.where((log) => log.coversDay(day)).firstOrNull;
  if (covering != null) {
    final dayNumber =
        _dateOnly(day).difference(_dateOnly(covering.startDate)).inDays + 1;
    return covering.isOngoing
        ? 'Bleeding · day $dayNumber of this period'
        : 'Day $dayNumber of a ${covering.durationInDays}-day period';
  }
  if (_isSameDay(day, stats.nextPredictedStart)) {
    return 'Predicted period start';
  }
  final lastStart = stats.currentCycleDay == null ? null : _latestStartDate(logs);
  if (lastStart != null && !day.isBefore(lastStart) && !day.isAfter(today)) {
    final cycleDay = _dateOnly(day).difference(_dateOnly(lastStart)).inDays + 1;
    return 'Cycle day $cycleDay';
  }
  return isFuture ? 'Upcoming' : 'No period data for this day';
}

DateTime? _latestStartDate(List<PeriodLogEntity> logs) {
  DateTime? latest;
  for (final log in logs) {
    if (latest == null || log.startDate.isAfter(latest)) {
      latest = log.startDate;
    }
  }
  return latest;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
