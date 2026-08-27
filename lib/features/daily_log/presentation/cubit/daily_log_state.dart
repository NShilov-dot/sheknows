import 'package:equatable/equatable.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/daily_log/domain/entities/daily_log_entity.dart';

sealed class DailyLogState extends Equatable {
  const DailyLogState();

  @override
  List<Object?> get props => [];
}

final class DailyLogInitial extends DailyLogState {
  const DailyLogInitial();
}

final class DailyLogLoading extends DailyLogState {
  const DailyLogLoading();
}

final class DailyLogReady extends DailyLogState {
  const DailyLogReady({
    required this.date,
    this.log,
    this.isSaving = false,
    this.savedAt = false,
    this.failure,
  });

  final DateTime date;

  /// Null when the day has no entry yet.
  final DailyLogEntity? log;
  final bool isSaving;

  /// Set briefly after a successful save so the UI can show confirmation.
  final bool savedAt;
  final Failure? failure;

  DailyLogReady copyWith({
    DateTime? date,
    DailyLogEntity? log,
    bool clearLog = false,
    bool? isSaving,
    bool? savedAt,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return DailyLogReady(
      date: date ?? this.date,
      log: clearLog ? null : (log ?? this.log),
      isSaving: isSaving ?? this.isSaving,
      savedAt: savedAt ?? false,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [date, log, isSaving, savedAt, failure];
}

final class DailyLogError extends DailyLogState {
  const DailyLogError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
