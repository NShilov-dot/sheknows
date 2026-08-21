import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_starter_kit/core/error/exceptions.dart' as app_exceptions;
import 'package:supabase_flutter_starter_kit/features/period/data/models/period_log_model.dart';
import 'package:supabase_flutter_starter_kit/features/period/domain/entities/period_log_entity.dart';

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
}

class PeriodRemoteDataSourceImpl implements PeriodRemoteDataSource {
  PeriodRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'period_logs';

  @override
  Future<List<PeriodLogModel>> getPeriodLogs(String userId) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: false);
      return rows.map(PeriodLogModel.fromJson).toList();
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to load period logs');
    }
  }

  @override
  Future<PeriodLogModel> logPeriodStart({
    required String userId,
    required DateTime startDate,
    FlowLevel? flow,
    String? notes,
  }) async {
    try {
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
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to log period');
    }
  }

  @override
  Future<PeriodLogModel> updatePeriodLog({
    required String periodId,
    DateTime? startDate,
    DateTime? endDate,
    FlowLevel? flow,
    String? notes,
  }) async {
    try {
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
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to update period');
    }
  }

  @override
  Future<void> deletePeriodLog(String periodId) async {
    try {
      await _client.from(_table).delete().eq('id', periodId);
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to delete period');
    }
  }

  static String? _cleanNotes(String? notes) {
    if (notes == null) {
      return null;
    }
    final trimmed = notes.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _dateString(DateTime date) {
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
