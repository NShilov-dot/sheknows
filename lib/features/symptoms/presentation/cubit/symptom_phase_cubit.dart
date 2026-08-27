import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/domain/usecases/period_usecases.dart';
import 'package:sheknows/features/symptoms/data/services/symptom_phase_analyzer.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_phase_trends.dart';
import 'package:sheknows/features/symptoms/domain/usecases/symptom_usecases.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/analytics_range.dart';

class SymptomPhaseCubit extends Cubit<SymptomPhaseState> {
  SymptomPhaseCubit({
    required GetSymptomLogsUseCase getSymptomLogs,
    required GetPeriodLogsUseCase getPeriodLogs,
    required SymptomPhaseAnalyzer analyzer,
  })  : _getSymptomLogs = getSymptomLogs,
        _getPeriodLogs = getPeriodLogs,
        _analyzer = analyzer,
        super(const SymptomPhaseInitial());

  final GetSymptomLogsUseCase _getSymptomLogs;
  final GetPeriodLogsUseCase _getPeriodLogs;
  final SymptomPhaseAnalyzer _analyzer;

  List<SymptomLogEntity> _symptomLogs = const [];
  List<PeriodLogEntity> _periodLogs = const [];
  AnalyticsRange _range = AnalyticsRange.days30;

  Future<void> load(String userId) async {
    emit(const SymptomPhaseLoading());

    // Both reads are independent — kick them off together.
    final symptomsFuture = _getSymptomLogs(GetSymptomLogsParams(userId: userId));
    final periodsFuture = _getPeriodLogs(GetPeriodLogsParams(userId: userId));
    final symptomsResult = await symptomsFuture;
    final periodsResult = await periodsFuture;

    await symptomsResult.fold(
      (failure) async => emit(SymptomPhaseError(failure)),
      (symptoms) => periodsResult.fold(
        (failure) async => emit(SymptomPhaseError(failure)),
        (periods) async {
          _symptomLogs = symptoms;
          _periodLogs = periods;
          await _recompute(_range);
        },
      ),
    );
  }

  Future<void> setRange(AnalyticsRange range) async {
    if (range == _range) {
      return;
    }
    _range = range;
    final current = state;
    if (current is SymptomPhaseLoaded) {
      emit(current.copyWith(range: range, recomputing: true));
    }
    await _recompute(range);
  }

  /// Runs the phase attribution in an isolate for [range] over the cached data.
  Future<void> _recompute(AnalyticsRange range) async {
    final now = DateTime.now();
    final input = SymptomPhaseInput(
      symptomLogs: _symptomLogs,
      periodLogs: _periodLogs,
      now: now,
      from: range.fromDate(now),
    );
    try {
      final trends = await _analyzer.analyze(input);
      emit(SymptomPhaseLoaded(trends: trends, range: range));
    } catch (_) {
      emit(const SymptomPhaseError(UnknownFailure()));
    }
  }
}
