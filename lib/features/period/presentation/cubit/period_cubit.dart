import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/domain/usecases/period_usecases.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';

class PeriodCubit extends Cubit<PeriodState> {
  PeriodCubit({
    required GetPeriodLogsUseCase getPeriodLogs,
    required LogPeriodStartUseCase logPeriodStart,
    required UpdatePeriodLogUseCase updatePeriodLog,
    required DeletePeriodLogUseCase deletePeriodLog,
    required GetDayLogsUseCase getDayLogs,
    required UpsertDayLogUseCase upsertDayLog,
    required DeleteDayLogUseCase deleteDayLog,
    required CycleStatsCalculator statsCalculator,
  })  : _getPeriodLogs = getPeriodLogs,
        _logPeriodStart = logPeriodStart,
        _updatePeriodLog = updatePeriodLog,
        _deletePeriodLog = deletePeriodLog,
        _getDayLogs = getDayLogs,
        _upsertDayLog = upsertDayLog,
        _deleteDayLog = deleteDayLog,
        _statsCalculator = statsCalculator,
        super(const PeriodInitial());

  final GetPeriodLogsUseCase _getPeriodLogs;
  final LogPeriodStartUseCase _logPeriodStart;
  final UpdatePeriodLogUseCase _updatePeriodLog;
  final DeletePeriodLogUseCase _deletePeriodLog;
  final GetDayLogsUseCase _getDayLogs;
  final UpsertDayLogUseCase _upsertDayLog;
  final DeleteDayLogUseCase _deleteDayLog;
  final CycleStatsCalculator _statsCalculator;

  String? _userId;

  Future<void> load(String userId) async {
    _userId = userId;
    emit(const PeriodLoading());
    final logsResult = await _getPeriodLogs(GetPeriodLogsParams(userId: userId));
    final dayResult = await _getDayLogs(GetDayLogsParams(userId: userId));
    logsResult.fold(
      (failure) => emit(PeriodError(failure)),
      (logs) => dayResult.fold(
        (failure) => emit(PeriodError(failure)),
        (dayLogs) => emit(_loadedState(logs, dayLogs)),
      ),
    );
  }

  void goToMonth(DateTime month) {
    final current = _loaded;
    if (current == null) {
      return;
    }
    emit(
      current.copyWith(
        displayedMonth: DateTime(month.year, month.month),
        clearMutationFailure: true,
      ),
    );
  }

  void previousMonth() {
    final current = _loaded;
    if (current == null) {
      return;
    }
    final month = current.displayedMonth;
    emit(
      current.copyWith(
        displayedMonth: DateTime(month.year, month.month - 1),
        clearMutationFailure: true,
      ),
    );
  }

  void nextMonth() {
    final current = _loaded;
    if (current == null) {
      return;
    }
    final month = current.displayedMonth;
    emit(
      current.copyWith(
        displayedMonth: DateTime(month.year, month.month + 1),
        clearMutationFailure: true,
      ),
    );
  }

  /// Logs a new period starting on [startDate]. Optimistically inserts a
  /// pending entry and reconciles with the server response.
  Future<void> startPeriod(DateTime startDate) async {
    final userId = _userId;
    final snapshot = _loaded;
    if (userId == null || snapshot == null || snapshot.isLoading) {
      return;
    }

    final optimisticId = 'pending-${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = PeriodLogEntity(
      id: optimisticId,
      userId: userId,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    emit(
      _withLogs(
        snapshot,
        [optimistic, ...snapshot.logs],
        isLoading: true,
      ),
    );

    final result = await _logPeriodStart(
      LogPeriodStartParams(userId: userId, startDate: startDate),
    );
    result.fold(
      (failure) => _rollback(snapshot, failure),
      (log) => _replaceAndFinish(optimisticId, log),
    );
  }

  /// Ends the ongoing period on [endDate] (inclusive last bleeding day).
  Future<void> endPeriod(DateTime endDate) async {
    final snapshot = _loaded;
    final ongoing = snapshot?.stats.currentPeriod;
    if (snapshot == null || ongoing == null || snapshot.isLoading) {
      return;
    }
    if (endDate.isBefore(ongoing.startDate)) {
      return;
    }

    final updated = _withEndDate(ongoing, endDate);
    emit(_withLogs(snapshot, _replaced(snapshot.logs, ongoing.id, updated)));

    final result = await _updatePeriodLog(
      UpdatePeriodLogParams(periodId: ongoing.id, endDate: updated.endDate),
    );
    result.fold(
      (failure) => _rollback(snapshot, failure),
      (log) => _replaceAndFinish(ongoing.id, log),
    );
  }

  /// Reopens an ended period by clearing its end date.
  Future<void> reopenPeriod(String periodId) async {
    final snapshot = _loaded;
    if (snapshot == null || snapshot.isLoading) {
      return;
    }
    final target =
        snapshot.logs.where((log) => log.id == periodId).firstOrNull;
    if (target == null) {
      return;
    }

    final reopened = PeriodLogEntity(
      id: target.id,
      userId: target.userId,
      startDate: target.startDate,
      flow: target.flow,
      notes: target.notes,
      createdAt: target.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    emit(_withLogs(snapshot, _replaced(snapshot.logs, periodId, reopened)));

    final result = await _updatePeriodLog(
      UpdatePeriodLogParams(periodId: periodId, endDate: null),
    );
    result.fold(
      (failure) => _rollback(snapshot, failure),
      (log) => _replaceAndFinish(periodId, log),
    );
  }

  Future<void> removePeriod(String periodId) async {
    final snapshot = _loaded;
    if (snapshot == null ||
        snapshot.isLoading ||
        periodId.startsWith('pending-')) {
      return;
    }

    final remaining =
        snapshot.logs.where((log) => log.id != periodId).toList();
    emit(_withLogs(snapshot, remaining));

    final result = await _deletePeriodLog(DeletePeriodLogParams(periodId));
    result.fold(
      (failure) => _rollback(snapshot, failure),
      (_) {
        final stateNow = _loaded;
        if (stateNow != null) {
          emit(stateNow.copyWith(isLoading: false, clearMutationFailure: true));
        }
      },
    );
  }

  // -- Day logs (intimacy / symptoms / mood / notes) -----------------------

  /// Creates or updates the day log for [date] with the given trackers.
  /// When every tracker is empty the day log is removed instead of stored.
  /// Optimistically applies the change and reconciles with the server.
  Future<void> saveDayLog(
    DateTime date, {
    SexualActivity? sexualActivity,
    Set<Symptom> symptoms = const {},
    Mood? mood,
    String? notes,
  }) async {
    final userId = _userId;
    final snapshot = _loaded;
    if (userId == null || snapshot == null || snapshot.isLoading) {
      return;
    }

    final day = _dateOnly(date);
    final existing = snapshot.dayLogFor(day);
    final now = DateTime.now().toUtc();
    final target = DayLogEntity(
      id: existing?.id ?? 'pending-${now.microsecondsSinceEpoch}',
      userId: userId,
      date: day,
      sexualActivity: sexualActivity,
      symptoms: symptoms,
      mood: mood,
      notes: notes,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    // Clearing every tracker removes the day log entirely.
    if (target.isEmpty) {
      if (existing != null) {
        await deleteDayLog(existing.id);
      }
      return;
    }

    emit(_withDayLogs(snapshot, _upsertedDayLogs(snapshot.dayLogs, target),
        isLoading: true));

    final result = await _upsertDayLog(
      UpsertDayLogParams(
        userId: userId,
        date: day,
        sexualActivity: sexualActivity,
        symptoms: symptoms,
        mood: mood,
        notes: notes,
      ),
    );
    result.fold(
      (failure) => _rollback(snapshot, failure),
      (saved) => _replaceDayLogAndFinish(day, saved),
    );
  }

  Future<void> deleteDayLog(String dayLogId) async {
    final snapshot = _loaded;
    if (snapshot == null ||
        snapshot.isLoading ||
        dayLogId.startsWith('pending-')) {
      return;
    }

    final remaining =
        snapshot.dayLogs.where((log) => log.id != dayLogId).toList();
    emit(snapshot.copyWith(dayLogs: remaining, clearMutationFailure: true));

    final result = await _deleteDayLog(DeleteDayLogParams(dayLogId));
    result.fold(
      (failure) => _rollback(snapshot, failure),
      (_) {
        final stateNow = _loaded;
        if (stateNow != null) {
          emit(stateNow.copyWith(isLoading: false, clearMutationFailure: true));
        }
      },
    );
  }

  // -- helpers -------------------------------------------------------------

  List<PeriodLogEntity> _replaced(
    List<PeriodLogEntity> logs,
    String id,
    PeriodLogEntity replacement,
  ) {
    return logs
        .map((log) => log.id == id ? replacement : log)
        .toList(growable: false);
  }

  PeriodLoaded _withLogs(
    PeriodLoaded base,
    List<PeriodLogEntity> logs, {
    bool isLoading = false,
  }) {
    final sorted = [...logs]..sort((a, b) => b.startDate.compareTo(a.startDate));
    return base.copyWith(
      logs: sorted,
      stats: _statsCalculator.calculate(sorted),
      isLoading: isLoading,
      // Forward progress (optimistic apply / reconcile) always clears a stale
      // failure — only _rollback sets one. Otherwise a later identical failure
      // would compare equal and the UI would swallow its snackbar.
      clearMutationFailure: true,
    );
  }

  PeriodLogEntity _withEndDate(PeriodLogEntity log, DateTime endDate) {
    return PeriodLogEntity(
      id: log.id,
      userId: log.userId,
      startDate: log.startDate,
      endDate: DateTime(endDate.year, endDate.month, endDate.day),
      flow: log.flow,
      notes: log.notes,
      createdAt: log.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  void _replaceAndFinish(String oldId, PeriodLogEntity replacement) {
    final stateNow = _loaded;
    if (stateNow == null) {
      return;
    }
    final logs = [
      for (final log in stateNow.logs)
        if (log.id == oldId) replacement else log,
    ];
    emit(_withLogs(stateNow, logs));
  }

  /// Replaces (by day) or inserts [entry] into [logs], newest day first.
  List<DayLogEntity> _upsertedDayLogs(
    List<DayLogEntity> logs,
    DayLogEntity entry,
  ) {
    final others =
        logs.where((log) => !log.isOnDay(entry.date)).toList(growable: true)
          ..add(entry)
          ..sort((a, b) => b.date.compareTo(a.date));
    return others;
  }

  PeriodLoaded _withDayLogs(
    PeriodLoaded base,
    List<DayLogEntity> dayLogs, {
    bool isLoading = false,
  }) {
    return base.copyWith(
      dayLogs: dayLogs,
      isLoading: isLoading,
      clearMutationFailure: true,
    );
  }

  void _replaceDayLogAndFinish(DateTime day, DayLogEntity saved) {
    final stateNow = _loaded;
    if (stateNow == null) {
      return;
    }
    emit(_withDayLogs(stateNow, _upsertedDayLogs(stateNow.dayLogs, saved)));
  }

  /// Restores the pre-mutation snapshot and surfaces the failure.
  void _rollback(PeriodLoaded snapshot, Failure failure) {
    emit(
      snapshot.copyWith(
        mutationFailure: failure,
        clearMutationFailure: false,
      ),
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  PeriodLoaded _loadedState(
    List<PeriodLogEntity> logs,
    List<DayLogEntity> dayLogs,
  ) {
    final now = DateTime.now();
    return PeriodLoaded(
      logs: [...logs]..sort((a, b) => b.startDate.compareTo(a.startDate)),
      dayLogs: [...dayLogs]..sort((a, b) => b.date.compareTo(a.date)),
      displayedMonth: DateTime(now.year, now.month),
      stats: _statsCalculator.calculate(logs),
    );
  }

  PeriodLoaded? get _loaded {
    final state = this.state;
    return state is PeriodLoaded ? state : null;
  }
}
