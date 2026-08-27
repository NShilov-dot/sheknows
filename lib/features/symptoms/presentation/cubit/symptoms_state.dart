import 'package:equatable/equatable.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';

sealed class SymptomsState extends Equatable {
  const SymptomsState();

  @override
  List<Object?> get props => [];
}

final class SymptomsInitial extends SymptomsState {
  const SymptomsInitial();
}

final class SymptomsLoading extends SymptomsState {
  const SymptomsLoading();
}

final class SymptomsLoaded extends SymptomsState {
  const SymptomsLoaded({
    required this.logs,
    this.isLoading = false,
    this.mutationFailure,
  });

  /// Logged symptoms, newest first.
  final List<SymptomLogEntity> logs;

  /// True while a mutation is in flight (optimistic updates are applied).
  final bool isLoading;
  final Failure? mutationFailure;

  SymptomsLoaded copyWith({
    List<SymptomLogEntity>? logs,
    bool? isLoading,
    Failure? mutationFailure,
    bool clearMutationFailure = false,
  }) {
    return SymptomsLoaded(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      mutationFailure: clearMutationFailure
          ? null
          : (mutationFailure ?? this.mutationFailure),
    );
  }

  @override
  List<Object?> get props => [logs, isLoading, mutationFailure];
}

final class SymptomsError extends SymptomsState {
  const SymptomsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
