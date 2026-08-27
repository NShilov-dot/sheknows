import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/symptoms/data/services/symptom_phase_analyzer.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_phase_trends.dart';

/// Exercises the real `compute()` path (a spawned isolate), which the cubit
/// test mocks out. Proves [SymptomPhaseInput]/[SymptomPhaseTrends] are actually
/// sendable across the isolate boundary and the entrypoint runs.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('analyze runs the computation in an isolate and returns a result',
      () async {
    final start = DateTime(2026, 6, 1);
    final input = SymptomPhaseInput(
      now: DateTime(2026, 9, 1),
      periodLogs: [
        for (var i = 0; i < 3; i++)
          PeriodLogEntity(
            id: 'p$i',
            userId: 'user-1',
            startDate: start.add(Duration(days: 28 * i)),
            endDate: start.add(Duration(days: 28 * i + 4)),
            createdAt: start,
            updatedAt: start,
          ),
      ],
      symptomLogs: [
        SymptomLogEntity(
          id: 's1',
          userId: 'user-1',
          type: SymptomType.cramps,
          severity: SymptomSeverity.moderate,
          loggedAt: start.add(const Duration(days: 76)), // luteal of 3rd cycle
          createdAt: start,
          updatedAt: start,
        ),
      ],
    );

    final trends = await const SymptomPhaseAnalyzer().analyze(input);

    expect(trends.totalEntries, 1);
    expect(
      trends.phases.firstWhere((s) => s.phase == CyclePhase.luteal).count,
      1,
    );
  });
}
