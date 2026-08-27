import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/core/utils/date_only.dart';

/// A phase of the menstrual cycle. [unknown] covers dates we can't place —
/// before any tracking, or without enough history to know the cycle length.
enum CyclePhase { menstrual, follicular, ovulation, luteal, unknown }

/// Classifies a calendar day into a [CyclePhase] from a user's period history.
/// Pure and stateless — mirrors [CycleStatsCalculator]. Feed it the averages
/// that calculator already produces rather than re-deriving them here.
class CyclePhaseCalculator {
  const CyclePhaseCalculator();

  /// Default menstruation length used only when no average is available yet.
  static const _fallbackPeriodLength = 5;

  /// Luteal phase is ~constant 14 days, so ovulation ≈ cycleLength - 14.
  static const _lutealLength = 14;

  CyclePhase phaseOn(
    DateTime day, {
    required List<PeriodLogEntity> periods,
    int? averageCycleLength,
    int? averagePeriodLength,
  }) {
    final d = day.dateOnly;

    // 1. Actual logged bleeding always wins.
    for (final period in periods) {
      if (period.coversDay(d)) {
        return CyclePhase.menstrual;
      }
    }

    // 2. The cycle that governs this day starts at the latest period start
    //    on or before it.
    DateTime? cycleStart;
    for (final period in periods) {
      final start = period.startDate.dateOnly;
      if (!start.isAfter(d) && (cycleStart == null || start.isAfter(cycleStart))) {
        cycleStart = start;
      }
    }
    if (cycleStart == null) {
      return CyclePhase.unknown; // predates tracking
    }

    // 3. Without a cycle length we can't place non-menstrual phases.
    if (averageCycleLength == null) {
      return CyclePhase.unknown;
    }

    // 4. Position within the cycle.
    final dayInCycle = d.difference(cycleStart).inDays + 1;
    final periodLen = averagePeriodLength ?? _fallbackPeriodLength;
    final ovulationDay =
        (averageCycleLength - _lutealLength).clamp(periodLen + 1, averageCycleLength);

    if (dayInCycle <= periodLen) {
      return CyclePhase.menstrual;
    }
    if (dayInCycle < ovulationDay - 1) {
      return CyclePhase.follicular;
    }
    if (dayInCycle <= ovulationDay + 1) {
      return CyclePhase.ovulation;
    }
    if (dayInCycle <= averageCycleLength) {
      return CyclePhase.luteal;
    }
    return CyclePhase.unknown; // late / irregular cycle
  }

}
