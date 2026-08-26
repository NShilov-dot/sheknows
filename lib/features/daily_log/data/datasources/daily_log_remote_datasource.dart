import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/core/error/exceptions.dart' as app_exceptions;
import 'package:sheknows/features/daily_log/data/models/daily_log_model.dart';

abstract class DailyLogRemoteDataSource {
  Future<DailyLogModel?> getDailyLog({
    required String userId,
    required DateTime date,
  });

  Future<DailyLogModel> upsertDailyLog(DailyLogModel log);
}

class DailyLogRemoteDataSourceImpl implements DailyLogRemoteDataSource {
  DailyLogRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'daily_logs';

  @override
  Future<DailyLogModel?> getDailyLog({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final local = date.toLocal();
      final day = '${local.year.toString().padLeft(4, '0')}-'
          '${local.month.toString().padLeft(2, '0')}-'
          '${local.day.toString().padLeft(2, '0')}';
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('log_date', day)
          .limit(1);
      if (rows.isEmpty) {
        return null;
      }
      return DailyLogModel.fromJson(rows.first);
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to load daily log');
    }
  }

  @override
  Future<DailyLogModel> upsertDailyLog(DailyLogModel log) async {
    try {
      final row = await _client
          .from(_table)
          .upsert(
            log.toUpsertJson(),
            onConflict: 'user_id,log_date',
          )
          .select()
          .single();
      return DailyLogModel.fromJson(row);
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to save daily log');
    }
  }
}
