import 'package:equatable/equatable.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_phase_trends.dart';
import 'package:sheknows/features/symptoms/presentation/utils/analytics_range.dart';

sealed class SymptomPhaseState extends Equatable {
  const SymptomPhaseState();

  @override
  List<Object?> get props => [];
}

final class SymptomPhaseInitial extends SymptomPhaseState {
  const SymptomPhaseInitial();
}

final class SymptomPhaseLoading extends SymptomPhaseState {
  const SymptomPhaseLoading();
}

final class SymptomPhaseLoaded extends SymptomPhaseState {
  const SymptomPhaseLoaded({
    required this.trends,
    required this.range,
    this.recomputing = false,
  });

  final SymptomPhaseTrends trends;
  final AnalyticsRange range;

  /// True while a window change is being re-computed in the isolate — lets the
  /// UI show a subtle indicator instead of a full-screen spinner.
  final bool recomputing;

  SymptomPhaseLoaded copyWith({
    SymptomPhaseTrends? trends,
    AnalyticsRange? range,
    bool? recomputing,
  }) {
    return SymptomPhaseLoaded(
      trends: trends ?? this.trends,
      range: range ?? this.range,
      recomputing: recomputing ?? this.recomputing,
    );
  }

  @override
  List<Object?> get props => [trends, range, recomputing];
}

final class SymptomPhaseError extends SymptomPhaseState {
  const SymptomPhaseError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
