import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';

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
  const calculator = CycleStatsCalculator();
  final now = DateTime(2026, 8, 21);

  group('CycleStatsCalculator', () {
    test('returns empty stats when no periods are logged', () {
      final stats = calculator.calculate(const [], now: now);

      expect(stats.periodCount, 0);
      expect(stats.hasPrediction, isFalse);
      expect(stats.currentCycleDay, isNull);
      expect(stats.currentPeriod, isNull);
    });

    test('does not predict with fewer than two periods', () {
      final stats = calculator.calculate(
        [_log(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 5))],
        now: now,
      );

      expect(stats.periodCount, 1);
      expect(stats.averageCycleLength, isNull);
      expect(stats.hasPrediction, isFalse);
      expect(stats.averagePeriodLength, 5);
    });

    test('computes average cycle length and next predicted start', () {
      final stats = calculator.calculate(
        [
          _log(id: 'a', start: DateTime(2026, 7, 1), end: DateTime(2026, 7, 5)),
          _log(id: 'b', start: DateTime(2026, 7, 29), end: DateTime(2026, 8, 2)),
          _log(id: 'c', start: DateTime(2026, 8, 26)),
        ],
        now: now,
      );

      // Cycles of 28 and 28 days.
      expect(stats.averageCycleLength, 28);
      // Last period started Aug 26; today is Aug 21, so the prediction rolls
      // forward to Sep 23.
      expect(
        stats.nextPredictedStart,
        DateTime(2026, 9, 23),
      );
    });

    test('detects an ongoing period as the current one', () {
      final ongoing = _log(start: DateTime(2026, 8, 18));
      final stats = calculator.calculate(
        [
          _log(id: 'a', start: DateTime(2026, 7, 20), end: DateTime(2026, 7, 24)),
          ongoing,
        ],
        now: now,
      );

      expect(stats.currentPeriod?.id, 'log-1');
      expect(stats.currentCycleDay, 4); // Aug 18 -> Aug 21 inclusive.
      expect(ongoing.isOngoing, isTrue);
      expect(ongoing.durationInDays, 4);
    });

    test('coversDay includes start and end dates', () {
      final log = _log(
        id: 'a',
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 5),
      );

      expect(log.coversDay(DateTime(2026, 8, 1)), isTrue);
      expect(log.coversDay(DateTime(2026, 8, 3)), isTrue);
      expect(log.coversDay(DateTime(2026, 8, 5)), isTrue);
      expect(log.coversDay(DateTime(2026, 7, 31)), isFalse);
      expect(log.coversDay(DateTime(2026, 8, 6)), isFalse);
    });

    test('ongoing period covers all days after its start', () {
      final log = _log(start: DateTime(2026, 8, 1));

      expect(log.coversDay(DateTime(2026, 12, 25)), isTrue);
    });

    test('uses only the most recent cycles for averages', () {
      final logs = <PeriodLogEntity>[
        for (var i = 0; i < kCycleAveragingWindow + 2; i++)
          _log(
            id: 'log-$i',
            start: DateTime(2026, 1, 1).add(Duration(days: 30 * i)),
            end: DateTime(2026, 1, 5).add(Duration(days: 30 * i)),
          ),
      ];
      final stats = calculator.calculate(logs, now: now);

      expect(stats.periodCount, kCycleAveragingWindow + 2);
      expect(stats.averageCycleLength, 30);
      expect(stats.averagePeriodLength, 5);
    });
  });
}
