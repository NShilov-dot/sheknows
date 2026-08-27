import 'package:equatable/equatable.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/core/utils/date_only.dart';

/// Number of past cycles used to compute averages and predictions.
const int kCycleAveragingWindow = 6;

class CycleStats extends Equatable {
  const CycleStats({
    required this.periodCount,
    this.averageCycleLength,
    this.averagePeriodLength,
    this.nextPredictedStart,
    this.currentPeriod,
    this.currentCycleDay,
  });

  final int periodCount;
  final int? averageCycleLength;
  final int? averagePeriodLength;
  final DateTime? nextPredictedStart;

  /// The ongoing period, if the user is currently bleeding.
  final PeriodLogEntity? currentPeriod;

  /// Day number within the current cycle (1 = first day of the most recent
  /// period). Null when there is no logged period yet.
  final int? currentCycleDay;

  bool get hasPrediction => nextPredictedStart != null;

  @override
  List<Object?> get props => [
        periodCount,
        averageCycleLength,
        averagePeriodLength,
        nextPredictedStart,
        currentPeriod,
        currentCycleDay,
      ];
}

class CycleStatsCalculator {
  const CycleStatsCalculator();

  /// [logs] may be in any order; they are sorted internally.
  CycleStats calculate(List<PeriodLogEntity> logs, {DateTime? now}) {
    final today = (now ?? DateTime.now()).dateOnly;
    final sorted = [...logs]..sort((a, b) => a.startDate.compareTo(b.startDate));

    if (sorted.isEmpty) {
      return const CycleStats(periodCount: 0);
    }

    // Cycle lengths between consecutive period starts.
    final cycleLengths = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      final length =
          sorted[i].startDate.dateOnly.difference(sorted[i - 1].startDate.dateOnly).inDays;
      if (length > 0) {
        cycleLengths.add(length);
      }
    }
    final recentCycles = cycleLengths.length > kCycleAveragingWindow
        ? cycleLengths.sublist(cycleLengths.length - kCycleAveragingWindow)
        : cycleLengths;
    final averageCycleLength = recentCycles.isEmpty
        ? null
        : (recentCycles.reduce((a, b) => a + b) / recentCycles.length).round();

    // Period lengths, using ended periods only for a stable average.
    final periodLengths = sorted
        .where((log) => !log.isOngoing)
        .map((log) => log.durationInDays)
        .toList();
    final recentPeriods = periodLengths.length > kCycleAveragingWindow
        ? periodLengths.sublist(periodLengths.length - kCycleAveragingWindow)
        : periodLengths;
    final averagePeriodLength = recentPeriods.isEmpty
        ? null
        : (recentPeriods.reduce((a, b) => a + b) / recentPeriods.length).round();

    final last = sorted.last;
    final currentPeriod = last.isOngoing ? last : null;

    DateTime? nextPredictedStart;
    if (averageCycleLength != null) {
      var predicted = _addDays(last.startDate.dateOnly, averageCycleLength);
      // If the prediction already passed (late period), roll forward until it
      // is in the future so the calendar always shows a meaningful marker.
      while (!predicted.isAfter(today)) {
        predicted = _addDays(predicted, averageCycleLength);
      }
      nextPredictedStart = predicted;
    }

    final currentCycleDay =
        today.difference(last.startDate.dateOnly).inDays + 1;

    return CycleStats(
      periodCount: sorted.length,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      nextPredictedStart: nextPredictedStart,
      currentPeriod: currentPeriod,
      currentCycleDay: currentCycleDay,
    );
  }

  DateTime _addDays(DateTime value, int days) =>
      DateTime(value.year, value.month, value.day + days);
}
