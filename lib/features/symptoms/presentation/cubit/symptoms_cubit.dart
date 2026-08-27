import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/usecases/symptom_usecases.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';

class SymptomsCubit extends Cubit<SymptomsState> {
  SymptomsCubit({
    required GetSymptomLogsUseCase getSymptomLogs,
    required LogSymptomUseCase logSymptom,
    required UpdateSymptomLogUseCase updateSymptomLog,
    required DeleteSymptomLogUseCase deleteSymptomLog,
  })  : _getSymptomLogs = getSymptomLogs,
        _logSymptom = logSymptom,
        _updateSymptomLog = updateSymptomLog,
        _deleteSymptomLog = deleteSymptomLog,
        super(const SymptomsInitial());

  final GetSymptomLogsUseCase _getSymptomLogs;
  final LogSymptomUseCase _logSymptom;
  final UpdateSymptomLogUseCase _updateSymptomLog;
  final DeleteSymptomLogUseCase _deleteSymptomLog;

  String? _userId;

  Future<void> load(String userId, {DateTime? from, DateTime? to}) async {
    _userId = userId;
    emit(const SymptomsLoading());
    final result = await _getSymptomLogs(
      GetSymptomLogsParams(userId: userId, from: from, to: to),
    );
    result.fold(
      (failure) => emit(SymptomsError(failure)),
      (logs) => emit(SymptomsLoaded(logs: _sorted(logs))),
    );
  }

  Future<void> logSymptom({
    required SymptomType type,
    required SymptomSeverity severity,
    required DateTime loggedAt,
    String? notes,
  }) async {
    final userId = _userId;
    final snapshot = _loaded;
    if (userId == null || snapshot == null || snapshot.isLoading) {
      return;
    }
    emit(snapshot.copyWith(isLoading: true, clearMutationFailure: true));

    final result = await _logSymptom(
      LogSymptomParams(
        userId: userId,
        type: type,
        severity: severity,
        loggedAt: loggedAt,
        notes: notes,
      ),
    );
    result.fold(
      (failure) => _rollback(snapshot, failure),
      (saved) => _emitLogs(_sorted([saved, ...snapshot.logs])),
    );
  }

  Future<void> updateSymptomLog({
    required String id,
    SymptomType? type,
    SymptomSeverity? severity,
    DateTime? loggedAt,
    String? notes,
  }) async {
    final snapshot = _loaded;
    if (snapshot == null || snapshot.isLoading) {
      return;
    }
    emit(snapshot.copyWith(isLoading: true, clearMutationFailure: true));

    final result = await _updateSymptomLog(
      UpdateSymptomLogParams(
        id: id,
        type: type,
        severity: severity,
        loggedAt: loggedAt,
        notes: notes,
      ),
    );
    result.fold(
      (failure) => _rollback(snapshot, failure),
      (saved) => _emitLogs(
        _sorted([
          for (final log in snapshot.logs)
            if (log.id == id) saved else log,
        ]),
      ),
    );
  }

  Future<void> deleteSymptomLog(String id) async {
    final snapshot = _loaded;
    if (snapshot == null || snapshot.isLoading) {
      return;
    }
    // Optimistically remove, then reconcile with the result.
    final remaining = snapshot.logs.where((log) => log.id != id).toList();
    emit(snapshot.copyWith(logs: remaining, clearMutationFailure: true));

    final result = await _deleteSymptomLog(DeleteSymptomLogParams(id));
    result.fold(
      (failure) => _rollback(snapshot, failure),
      (_) => _emitLogs(remaining),
    );
  }

  // -- helpers -------------------------------------------------------------

  void _emitLogs(List<SymptomLogEntity> logs) {
    final current = _loaded;
    if (current == null) {
      return;
    }
    emit(current.copyWith(
      logs: logs,
      isLoading: false,
      clearMutationFailure: true,
    ));
  }

  void _rollback(SymptomsLoaded snapshot, Failure failure) {
    emit(snapshot.copyWith(mutationFailure: failure));
  }

  static List<SymptomLogEntity> _sorted(List<SymptomLogEntity> logs) =>
      [...logs]..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

  SymptomsLoaded? get _loaded {
    final state = this.state;
    return state is SymptomsLoaded ? state : null;
  }
}
