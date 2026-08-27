import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/utils/day_status.dart';

PeriodLogEntity _log({
  required DateTime start,
  DateTime? end,
  String id = 'log-1',
}) {
  return PeriodLogEntity(
    id: id,
    userId: 'user-1',
    startDate: start,
    endDate: end,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  final today = DateTime(2026, 8, 21);
  final logs = [
    _log(start: DateTime(2026, 7, 1), end: DateTime(2026, 7, 5), id: 'a'),
    _log(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 5), id: 'b'),
  ];
  final stats = const CycleStatsCalculator().calculate(logs, now: today);

  String labelFor(DateTime day) => dayStatusLabel(
        day: day,
        today: today,
        logs: logs,
        stats: stats,
      );

  test('labels a day inside a finished period', () {
    expect(labelFor(DateTime(2026, 8, 2)), 'Day 2 of a 5-day period');
  });

  test('labels a day inside an ongoing period', () {
    final ongoing = [_log(start: DateTime(2026, 8, 19), id: 'c')];
    expect(
      dayStatusLabel(
        day: DateTime(2026, 8, 20),
        today: today,
        logs: ongoing,
        stats: const CycleStatsCalculator().calculate(ongoing, now: today),
      ),
      'Bleeding · day 2 of this period',
    );
  });

  test('labels the predicted start', () {
    expect(labelFor(stats.nextPredictedStart!), 'Predicted period start');
  });

  test('labels the current cycle day', () {
    expect(labelFor(DateTime(2026, 8, 10)), 'Cycle day 10');
  });

  test('labels a future day with no data', () {
    expect(labelFor(DateTime(2026, 12, 25)), 'Upcoming');
  });

  test('labels a past day with no data', () {
    expect(labelFor(DateTime(2026, 1, 1)), 'No period data for this day');
  });
}
