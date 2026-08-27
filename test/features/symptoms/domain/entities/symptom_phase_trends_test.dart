import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_phase_trends.dart';

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

SymptomLogEntity _symptom(SymptomType type, DateTime at) {
  return SymptomLogEntity(
    id: 's-${type.name}-${at.microsecondsSinceEpoch}',
    userId: 'user-1',
    type: type,
    severity: SymptomSeverity.moderate,
    loggedAt: at,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  const calculator = SymptomPhaseCalculator();

  final s0 = DateTime(2026, 6, 1);
  final s1 = s0.add(const Duration(days: 28));
  final s2 = s0.add(const Duration(days: 56)); // last cycle start
  final periods = [_period(s0), _period(s1), _period(s2)];
  final now = DateTime(2026, 9, 1);

  PhaseSummary summaryFor(SymptomPhaseTrends trends, CyclePhase phase) =>
      trends.phases.firstWhere((s) => s.phase == phase);

  group('SymptomPhaseCalculator', () {
    test('attributes symptoms to the right phases', () {
      final trends = calculator.calculate(
        SymptomPhaseInput(
          symptomLogs: [
            _symptom(SymptomType.nausea, s2.add(const Duration(days: 2))), // menstrual
            _symptom(SymptomType.acne, s2.add(const Duration(days: 8))), // follicular
            _symptom(SymptomType.cramps, s2.add(const Duration(days: 20))), // luteal
            _symptom(SymptomType.cramps, s2.add(const Duration(days: 21))), // luteal
          ],
          periodLogs: periods,
          now: now,
        ),
      );

      expect(trends.totalEntries, 4);
      expect(summaryFor(trends, CyclePhase.menstrual).count, 1);
      expect(summaryFor(trends, CyclePhase.follicular).count, 1);
      final luteal = summaryFor(trends, CyclePhase.luteal);
      expect(luteal.count, 2);
      expect(luteal.topTypes.first.type, SymptomType.cramps);
      expect(luteal.topTypes.first.count, 2);
      expect(trends.maxPhaseCount, 2);
    });

    test('every phase is present even with no data', () {
      final trends = calculator.calculate(
        SymptomPhaseInput(symptomLogs: const [], periodLogs: periods, now: now),
      );
      expect(trends.isEmpty, isTrue);
      expect(trends.phases.map((s) => s.phase), CyclePhase.values);
      expect(trends.phases.every((s) => s.count == 0), isTrue);
    });

    test('from excludes symptoms before the window', () {
      final trends = calculator.calculate(
        SymptomPhaseInput(
          symptomLogs: [
            _symptom(SymptomType.cramps, s2.add(const Duration(days: 20))),
            _symptom(SymptomType.headache, s0.add(const Duration(days: 2))),
          ],
          periodLogs: periods,
          now: now,
          from: s2, // excludes the s0-era symptom
        ),
      );
      expect(trends.totalEntries, 1);
      expect(summaryFor(trends, CyclePhase.luteal).count, 1);
    });
  });
}
