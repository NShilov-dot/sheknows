import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/core/utils/date_only.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Human-readable description of what [day] means for the cycle: which day of
/// a logged period it is, whether it is the predicted start, the cycle day, or
/// that nothing is known about it.
///
/// [today] is a parameter rather than a `DateTime.now()` call so that the
/// caller and this function cannot disagree across a midnight boundary.
String dayStatusLabel({
  required AppLocalizations l10n,
  required DateTime day,
  required DateTime today,
  required List<PeriodLogEntity> logs,
  required CycleStats stats,
}) {
  final isFuture = day.isAfter(today);
  final covering = logs.where((log) => log.coversDay(day)).firstOrNull;
  if (covering != null) {
    final dayNumber =
        day.dateOnly.difference(covering.startDate.dateOnly).inDays + 1;
    return covering.isOngoing
        ? l10n.cycleStatusBleedingDay(dayNumber)
        : l10n.cycleStatusDayOfPeriod(covering.durationInDays, dayNumber);
  }
  if (_isSameDay(day, stats.nextPredictedStart)) {
    return l10n.cycleStatusPredictedStart;
  }
  final lastStart = stats.currentCycleDay == null ? null : _latestStartDate(logs);
  if (lastStart != null && !day.isBefore(lastStart) && !day.isAfter(today)) {
    final cycleDay = day.dateOnly.difference(lastStart.dateOnly).inDays + 1;
    return l10n.cycleStatusCycleDay(cycleDay);
  }
  return isFuture ? l10n.cycleStatusUpcoming : l10n.cycleStatusNoData;
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

bool _isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
