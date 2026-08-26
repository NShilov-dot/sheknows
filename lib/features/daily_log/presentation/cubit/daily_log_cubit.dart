import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:sheknows/features/daily_log/domain/usecases/daily_log_usecases.dart';
import 'package:sheknows/features/daily_log/presentation/cubit/daily_log_state.dart';

class DailyLogCubit extends Cubit<DailyLogState> {
  DailyLogCubit({
    required GetDailyLogUseCase getDailyLog,
    required SaveDailyLogUseCase saveDailyLog,
  })  : _getDailyLog = getDailyLog,
        _saveDailyLog = saveDailyLog,
        super(const DailyLogInitial());

  final GetDailyLogUseCase _getDailyLog;
  final SaveDailyLogUseCase _saveDailyLog;

  String? _userId;

  Future<void> loadForDate(String userId, DateTime date) async {
    _userId = userId;
    emit(const DailyLogLoading());
    final result = await _getDailyLog(
      GetDailyLogParams(userId: userId, date: date),
    );
    result.fold(
      (failure) => emit(DailyLogError(failure)),
      (log) => emit(
        DailyLogReady(date: _dateOnly(date), log: log),
      ),
    );
  }

  /// Creates or updates the log for the currently loaded day.
  Future<void> save({
    required Mood? mood,
    required List<String> symptoms,
    String? notes,
  }) async {
    final userId = _userId;
    final current = state;
    if (userId == null || current is! DailyLogReady || current.isSaving) {
      return;
    }

    final existing = current.log;
    final updated = DailyLogEntity(
      id: existing?.id ?? '',
      userId: userId,
      date: current.date,
      mood: mood,
      symptoms: symptoms,
      notes: notes,
      createdAt: existing?.createdAt ?? DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    emit(current.copyWith(isSaving: true, clearFailure: true));

    final result = await _saveDailyLog(updated);
    result.fold(
      (failure) {
        final now = state;
        if (now is DailyLogReady) {
          emit(now.copyWith(isSaving: false, failure: failure));
        }
      },
      (saved) {
        final now = state;
        if (now is DailyLogReady) {
          emit(now.copyWith(log: saved, isSaving: false, savedAt: true));
        }
      },
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
