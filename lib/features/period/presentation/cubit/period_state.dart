import 'package:equatable/equatable.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/features/period/domain/entities/cycle_stats.dart';
import 'package:supabase_flutter_starter_kit/features/period/domain/entities/period_log_entity.dart';

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
    required this.displayedMonth,
    required this.stats,
    this.isLoading = false,
    this.mutationFailure,
  });

  /// All logs, newest first.
  final List<PeriodLogEntity> logs;
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

  PeriodLoaded copyWith({
    List<PeriodLogEntity>? logs,
    DateTime? displayedMonth,
    CycleStats? stats,
    bool? isLoading,
    Failure? mutationFailure,
    bool clearMutationFailure = false,
  }) {
    return PeriodLoaded(
      logs: logs ?? this.logs,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      mutationFailure:
          clearMutationFailure ? null : (mutationFailure ?? this.mutationFailure),
    );
  }

  @override
  List<Object?> get props =>
      [logs, displayedMonth, stats, isLoading, mutationFailure];
}

final class PeriodError extends PeriodState {
  const PeriodError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
