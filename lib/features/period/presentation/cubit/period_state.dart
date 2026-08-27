import 'package:equatable/equatable.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';

sealed class PeriodState extends Equatable {
  const PeriodState();

  @override
  List<Object?> get props => [];
}

final class PeriodInitial extends PeriodState {
  const PeriodInitial();
}

final class PeriodLoading extends PeriodState {
  const PeriodLoading();
}

final class PeriodLoaded extends PeriodState {
  const PeriodLoaded({
    required this.logs,
    required this.dayLogs,
    required this.displayedMonth,
    required this.stats,
    this.isLoading = false,
    this.mutationFailure,
  });

  /// Period episodes, newest first.
  final List<PeriodLogEntity> logs;

  /// Per-day logs (intimacy/symptoms/mood/notes), newest first.
  final List<DayLogEntity> dayLogs;

  final DateTime displayedMonth;
  final CycleStats stats;

  /// True while a mutation is in flight (optimistic updates are applied).
  final bool isLoading;
  final Failure? mutationFailure;

  List<PeriodLogEntity> get logsForDisplayedMonth => logs
      .where((log) =>
          log.startDate.year == displayedMonth.year &&
          log.startDate.month == displayedMonth.month)
      .toList();

  /// The day log for [day], or null when nothing is tracked that day.
  DayLogEntity? dayLogFor(DateTime day) {
    for (final log in dayLogs) {
      if (log.isOnDay(day)) {
        return log;
      }
    }
    return null;
  }

  PeriodLoaded copyWith({
    List<PeriodLogEntity>? logs,
    List<DayLogEntity>? dayLogs,
    DateTime? displayedMonth,
    CycleStats? stats,
    bool? isLoading,
    Failure? mutationFailure,
    bool clearMutationFailure = false,
  }) {
    return PeriodLoaded(
      logs: logs ?? this.logs,
      dayLogs: dayLogs ?? this.dayLogs,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      mutationFailure:
          clearMutationFailure ? null : (mutationFailure ?? this.mutationFailure),
    );
  }

  @override
  List<Object?> get props =>
      [logs, dayLogs, displayedMonth, stats, isLoading, mutationFailure];
}

final class PeriodError extends PeriodState {
  const PeriodError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
