import 'package:flutter/material.dart';
import 'package:supabase_flutter_starter_kit/features/period/domain/entities/cycle_stats.dart';
import 'package:supabase_flutter_starter_kit/features/period/domain/entities/period_log_entity.dart';
import 'package:supabase_flutter_starter_kit/features/period/presentation/cubit/period_cubit.dart';

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Bottom sheet shown when a calendar day is tapped. Offers the actions
/// that make sense for that day: log a start, end the ongoing period, or
/// delete the covering period.
class DayDetailsSheet extends StatelessWidget {
  const DayDetailsSheet({
    super.key,
    required this.day,
    required this.logs,
    required this.stats,
    required this.cubit,
  });

  final DateTime day;
  final List<PeriodLogEntity> logs;
  final CycleStats stats;
  final PeriodCubit cubit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today = DateTime.now();
    final isFuture = day.isAfter(today);

    final covering =
        logs.where((log) => log.coversDay(day)).firstOrNull;
    final ongoing = stats.currentPeriod;
    final canEndHere = ongoing != null &&
        !day.isBefore(ongoing.startDate) &&
        !day.isAfter(today);
    final canStartHere = covering == null && !isFuture;
    final isPredictedStart = _isSameDay(day, stats.nextPredictedStart);

    String status;
    if (covering != null) {
      final dayNumber =
          DateTime(day.year, day.month, day.day)
              .difference(_dateOnly(covering.startDate))
              .inDays +
              1;
      status = covering.isOngoing
          ? 'Bleeding · day $dayNumber of this period'
          : 'Day $dayNumber of a ${covering.durationInDays}-day period';
    } else if (isPredictedStart) {
      status = 'Predicted period start';
    } else {
      final lastStart = stats.currentCycleDay == null
          ? null
          : _latestStartDate(logs);
      if (lastStart != null &&
          !day.isBefore(lastStart) &&
          !day.isAfter(today)) {
        final cycleDay =
            DateTime(day.year, day.month, day.day)
                .difference(_dateOnly(lastStart))
                .inDays +
                1;
        status = 'Cycle day $cycleDay';
      } else if (isFuture) {
        status = 'Upcoming';
      } else {
        status = 'No data for this day';
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${_weekdayNames[day.weekday - 1]}, '
              '${day.day} ${_monthNames[day.month - 1]} ${day.year}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    status,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (canStartHere)
              FilledButton.icon(
                onPressed: () => _run(context, () => cubit.startPeriod(day)),
                icon: const Icon(Icons.water_drop),
                label: const Text('Period started on this day'),
              ),
            if (canEndHere) ...[
              if (canStartHere) const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _run(context, () => cubit.endPeriod(day)),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('End period on this day'),
              ),
            ],
            if (covering != null &&
                !covering.id.startsWith('pending-')) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () =>
                    _run(context, () => cubit.removePeriod(covering.id)),
                icon: Icon(Icons.delete_outline, color: scheme.error),
                label: Text(
                  'Delete this period',
                  style: TextStyle(color: scheme.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _run(BuildContext context, VoidCallback action) {
    action();
    Navigator.of(context).pop();
  }

  static DateTime? _latestStartDate(List<PeriodLogEntity> logs) {
    DateTime? latest;
    for (final log in logs) {
      if (latest == null || log.startDate.isAfter(latest)) {
        latest = log.startDate;
      }
    }
    return latest;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
