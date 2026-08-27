import 'package:equatable/equatable.dart';
import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_trends.dart';

/// Everything the phase computation needs, bundled so it can be sent to an
/// isolate via [compute]. All fields are plain data (isolate-sendable by copy).
/// [now] is passed in rather than read inside the isolate for determinism.
class SymptomPhaseInput {
  const SymptomPhaseInput({
    required this.symptomLogs,
    required this.periodLogs,
    required this.now,
    this.from,
  });

  final List<SymptomLogEntity> symptomLogs;
  final List<PeriodLogEntity> periodLogs;
  final DateTime now;
  final DateTime? from;
}

/// Symptoms logged in one cycle phase: how many, and which types dominate.
class PhaseSummary extends Equatable {
  const PhaseSummary({
    required this.phase,
    required this.count,
    required this.topTypes,
  });

  final CyclePhase phase;
  final int count;

  /// Most frequent symptom types in this phase, highest first (up to 3).
  final List<SymptomTypeCount> topTypes;

  @override
  List<Object?> get props => [phase, count, topTypes];
}

/// Per-phase attribution of a user's symptom history over a window.
class SymptomPhaseTrends extends Equatable {
  const SymptomPhaseTrends({
    required this.phases,
    required this.totalEntries,
  });

  /// One entry per [CyclePhase], in enum order (menstrual…unknown).
  final List<PhaseSummary> phases;
  final int totalEntries;

  bool get isEmpty => totalEntries == 0;

  /// Highest single-phase count, for scaling bars (>= 1 to avoid /0).
  int get maxPhaseCount => phases.fold(
        1,
        (max, summary) => summary.count > max ? summary.count : max,
      );

  @override
  List<Object?> get props => [phases, totalEntries];
}

class SymptomPhaseCalculator {
  const SymptomPhaseCalculator();

  static const _topTypesPerPhase = 3;

  SymptomPhaseTrends calculate(SymptomPhaseInput input) {
    final from = input.from;
    final scoped = from == null
        ? input.symptomLogs
        : input.symptomLogs
            .where((log) => !log.loggedAt.isBefore(from))
            .toList();

    final stats =
        const CycleStatsCalculator().calculate(input.periodLogs, now: input.now);
    const phaseCalculator = CyclePhaseCalculator();

    // phase -> (symptom type -> count)
    final byPhase = <CyclePhase, Map<SymptomType, int>>{
      for (final phase in CyclePhase.values) phase: <SymptomType, int>{},
    };
    for (final log in scoped) {
      final phase = phaseCalculator.phaseOn(
        log.loggedAt,
        periods: input.periodLogs,
        averageCycleLength: stats.averageCycleLength,
        averagePeriodLength: stats.averagePeriodLength,
      );
      byPhase[phase]!.update(log.type, (value) => value + 1, ifAbsent: () => 1);
    }

    final phases = [
      for (final phase in CyclePhase.values)
        PhaseSummary(
          phase: phase,
          count: byPhase[phase]!.values.fold(0, (sum, c) => sum + c),
          topTypes: _topTypes(byPhase[phase]!),
        ),
    ];

    return SymptomPhaseTrends(phases: phases, totalEntries: scoped.length);
  }

  List<SymptomTypeCount> _topTypes(Map<SymptomType, int> counts) {
    final ranked = counts.entries
        .map((entry) => SymptomTypeCount(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.count != a.count
          ? b.count.compareTo(a.count)
          : a.type.index.compareTo(b.type.index));
    return ranked.take(_topTypesPerPhase).toList();
  }
}

/// Isolate entrypoint: top-level, no captured state. Dispatched via [compute]
/// from `SymptomPhaseAnalyzer`.
SymptomPhaseTrends computeSymptomPhaseTrends(SymptomPhaseInput input) =>
    const SymptomPhaseCalculator().calculate(input);
