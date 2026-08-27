import 'package:sheknows/core/error/exceptions.dart' as app_exceptions;
import 'package:sheknows/features/period/data/datasources/period_remote_datasource.dart';
import 'package:sheknows/features/period/data/models/day_log_model.dart';
import 'package:sheknows/features/period/data/models/period_log_model.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/core/utils/date_only.dart';

/// DEV_MODE period store: in-memory, no Supabase. Seeded with a few cycles so
/// the calendar, stats, and predictions have something to render. Data resets
/// on every app restart.
class DevPeriodRemoteDataSource implements PeriodRemoteDataSource {
  DevPeriodRemoteDataSource() {
    _seed();
  }

  final List<PeriodLogModel> _periods = [];
  final List<DayLogModel> _days = [];
  int _seq = 0;

  String _id() => 'dev-${_seq++}';

  void _seed() {
    final now = DateTime.now();
    final anchor = now.dateOnly;
    // Three ~28-day cycles of 5 bleeding days each (need >=2 for predictions).
    for (var i = 3; i >= 1; i--) {
      final start = anchor.subtract(Duration(days: 28 * i));
      _periods.add(
        PeriodLogModel(
          id: _id(),
          userId: 'dev-user',
          startDate: start,
          endDate: start.add(const Duration(days: 4)),
          flow: FlowLevel.medium,
          createdAt: start,
          updatedAt: start,
        ),
      );
    }
  }

  @override
  Future<List<PeriodLogModel>> getPeriodLogs(String userId) async {
    return [..._periods]..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  @override
  Future<PeriodLogModel> logPeriodStart({
    required String userId,
    required DateTime startDate,
    FlowLevel? flow,
    String? notes,
  }) async {
    final now = DateTime.now();
    final log = PeriodLogModel(
      id: _id(),
      userId: userId,
      startDate: startDate.dateOnly,
      flow: flow,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    _periods.add(log);
    return log;
  }

  @override
  Future<PeriodLogModel> updatePeriodLog({
    required String periodId,
    DateTime? startDate,
    DateTime? endDate,
    FlowLevel? flow,
    String? notes,
  }) async {
    final index = _periods.indexWhere((p) => p.id == periodId);
    if (index == -1) {
      throw const app_exceptions.ServerException('Period not found');
    }
    final current = _periods[index];
    // Mirrors the Supabase impl: endDate is written as-is (null reopens),
    // other fields only when provided.
    final updated = PeriodLogModel(
      id: current.id,
      userId: current.userId,
      startDate: startDate ?? current.startDate,
      endDate: endDate,
      flow: flow ?? current.flow,
      notes: notes ?? current.notes,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    _periods[index] = updated;
    return updated;
  }

  @override
  Future<void> deletePeriodLog(String periodId) async {
    _periods.removeWhere((p) => p.id == periodId);
  }

  @override
  Future<List<DayLogModel>> getDayLogs(String userId) async {
    return [..._days]..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<DayLogModel> upsertDayLog({
    required String userId,
    required DateTime date,
    SexualActivity? sexualActivity,
    String? notes,
  }) async {
    final day = date.dateOnly;
    final index = _days.indexWhere((d) => d.userId == userId && d.isOnDay(day));
    final now = DateTime.now();
    final model = DayLogModel(
      id: index == -1 ? _id() : _days[index].id,
      userId: userId,
      date: day,
      sexualActivity: sexualActivity,
      notes: notes,
      createdAt: index == -1 ? now : _days[index].createdAt,
      updatedAt: now,
    );
    if (index == -1) {
      _days.add(model);
    } else {
      _days[index] = model;
    }
    return model;
  }

  @override
  Future<void> deleteDayLog(String dayLogId) async {
    _days.removeWhere((d) => d.id == dayLogId);
  }
}
