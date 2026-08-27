import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/core/error/remote_call.dart';
import 'package:sheknows/core/utils/date_only.dart';
import 'package:sheknows/features/period/data/models/day_log_model.dart';
import 'package:sheknows/features/period/data/models/period_log_model.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';

abstract class PeriodRemoteDataSource {
  Future<List<PeriodLogModel>> getPeriodLogs(String userId);

  Future<PeriodLogModel> logPeriodStart({
    required String userId,
    required DateTime startDate,
    FlowLevel? flow,
    String? notes,
  });

  Future<PeriodLogModel> updatePeriodLog({
    required String periodId,
    DateTime? startDate,
    DateTime? endDate,
    FlowLevel? flow,
    String? notes,
  });

  Future<void> deletePeriodLog(String periodId);

  Future<List<DayLogModel>> getDayLogs(String userId);

  Future<DayLogModel> upsertDayLog({
    required String userId,
    required DateTime date,
    SexualActivity? sexualActivity,
    String? notes,
  });

  Future<void> deleteDayLog(String dayLogId);
}

class PeriodRemoteDataSourceImpl implements PeriodRemoteDataSource {
  PeriodRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'period_logs';
  static const _dayTable = 'day_logs';

  @override
  Future<List<PeriodLogModel>> getPeriodLogs(String userId) => supabaseCall(
        () async {
          final rows = await _client
              .from(_table)
              .select()
              .eq('user_id', userId)
              .order('start_date', ascending: false);
          return rows.map(PeriodLogModel.fromJson).toList();
        },
        'Failed to load period logs',
      );

  @override
  Future<PeriodLogModel> logPeriodStart({
    required String userId,
    required DateTime startDate,
    FlowLevel? flow,
    String? notes,
  }) =>
      supabaseCall(
        () async {
          final row = await _client
              .from(_table)
              .insert(
                PeriodLogModel(
                  id: '',
                  userId: userId,
                  startDate: startDate,
                  flow: flow,
                  notes: notes,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ).toInsertJson(),
              )
              .select()
              .single();
          return PeriodLogModel.fromJson(row);
        },
        'Failed to log period',
      );

  @override
  Future<PeriodLogModel> updatePeriodLog({
    required String periodId,
    DateTime? startDate,
    DateTime? endDate,
    FlowLevel? flow,
    String? notes,
  }) =>
      supabaseCall(
        () async {
          final updates = <String, dynamic>{
            if (startDate != null) 'start_date': _dateString(startDate),
            // An explicit null clears the end date (reopens the period).
            'end_date': endDate == null ? null : _dateString(endDate),
            if (flow != null) 'flow': flow.name,
            if (notes != null) 'notes': _cleanNotes(notes),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          };
          final row = await _client
              .from(_table)
              .update(updates)
              .eq('id', periodId)
              .select()
              .single();
          return PeriodLogModel.fromJson(row);
        },
        'Failed to update period',
      );

  @override
  Future<void> deletePeriodLog(String periodId) => supabaseCall(
        () => _client.from(_table).delete().eq('id', periodId),
        'Failed to delete period',
      );

  @override
  Future<List<DayLogModel>> getDayLogs(String userId) => supabaseCall(
        () async {
          final rows = await _client
              .from(_dayTable)
              .select()
              .eq('user_id', userId)
              .order('log_date', ascending: false);
          return rows.map(DayLogModel.fromJson).toList();
        },
        'Failed to load day logs',
      );

  @override
  Future<DayLogModel> upsertDayLog({
    required String userId,
    required DateTime date,
    SexualActivity? sexualActivity,
    String? notes,
  }) =>
      supabaseCall(
        () async {
          final row = await _client
              .from(_dayTable)
              .upsert(
                DayLogModel(
                  id: '',
                  userId: userId,
                  date: date,
                  sexualActivity: sexualActivity,
                  notes: notes,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ).toUpsertJson(),
                onConflict: 'user_id,log_date',
              )
              .select()
              .single();
          return DayLogModel.fromJson(row);
        },
        'Failed to save day log',
      );

  @override
  Future<void> deleteDayLog(String dayLogId) => supabaseCall(
        () => _client.from(_dayTable).delete().eq('id', dayLogId),
        'Failed to delete day log',
      );

  static String? _cleanNotes(String? notes) {
    final trimmed = notes?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static String _dateString(DateTime date) {
    final local = date.toLocal().dateOnly;
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
