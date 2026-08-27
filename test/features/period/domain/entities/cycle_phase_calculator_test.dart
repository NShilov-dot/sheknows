import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';

/// A 5-day period starting on [start] (inclusive end = start + 4).
PeriodLogEntity _period(DateTime start) {
  return PeriodLogEntity(
    id: 'p-${start.toIso8601String()}',
    userId: 'user-1',
    startDate: start,
    endDate: start.add(const Duration(days: 4)),
    createdAt: start,
    updatedAt: start,
  );
}

void main() {
  const calculator = CyclePhaseCalculator();

  // Three ~28-day cycles of 5-day periods. avgCycle = 28, avgPeriod = 5,
  // so ovulation day ≈ 28 - 14 = 14, fertile window [13, 15].
  final s0 = DateTime(2026, 6, 1);
  final s1 = s0.add(const Duration(days: 28));
  final s2 = s0.add(const Duration(days: 56));
  final periods = [_period(s0), _period(s1), _period(s2)];

  CyclePhase phaseOn(DateTime day) => calculator.phaseOn(
        day,
        periods: periods,
        averageCycleLength: 28,
        averagePeriodLength: 5,
      );

  group('CyclePhaseCalculator', () {
    test('a logged bleeding day is menstrual', () {
      expect(phaseOn(s2.add(const Duration(days: 2))), CyclePhase.menstrual);
    });

    test('post-period, pre-ovulation is follicular', () {
      // dayInCycle 9 (> periodLen 5, < ovulation-1 = 13).
      expect(phaseOn(s2.add(const Duration(days: 8))), CyclePhase.follicular);
    });

    test('the fertile window is ovulation', () {
      // dayInCycle 14.
      expect(phaseOn(s2.add(const Duration(days: 13))), CyclePhase.ovulation);
    });

    test('after ovulation until the next cycle is luteal', () {
      // dayInCycle 21.
      expect(phaseOn(s2.add(const Duration(days: 20))), CyclePhase.luteal);
    });

    test('a day before any tracking is unknown', () {
      expect(phaseOn(s0.subtract(const Duration(days: 10))), CyclePhase.unknown);
    });

    test('without an average cycle length only actual bleeding is placed', () {
      CyclePhase p(DateTime day) =>
          calculator.phaseOn(day, periods: periods, averageCycleLength: null);
      expect(p(s2.add(const Duration(days: 2))), CyclePhase.menstrual); // covered
      expect(p(s2.add(const Duration(days: 20))), CyclePhase.unknown); // no length
    });
  });
}
