import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/core/error/remote_call.dart';
import 'package:sheknows/features/symptoms/data/models/symptom_log_model.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';

abstract class SymptomRemoteDataSource {
  Future<List<SymptomLogModel>> getSymptomLogs(
    String userId, {
    DateTime? from,
    DateTime? to,
  });

  Future<SymptomLogModel> logSymptom({
    required String userId,
    required SymptomType type,
    required SymptomSeverity severity,
    required DateTime loggedAt,
    String? notes,
  });

  Future<SymptomLogModel> updateSymptomLog({
    required String id,
    SymptomType? type,
    SymptomSeverity? severity,
    DateTime? loggedAt,
    String? notes,
  });

  Future<void> deleteSymptomLog(String id);
}

class SymptomRemoteDataSourceImpl implements SymptomRemoteDataSource {
  SymptomRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'symptom_logs';

  @override
  Future<List<SymptomLogModel>> getSymptomLogs(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) =>
      supabaseCall(
        () async {
          var query = _client.from(_table).select().eq('user_id', userId);
          if (from != null) {
            query = query.gte('logged_at', from.toUtc().toIso8601String());
          }
          if (to != null) {
            query = query.lte('logged_at', to.toUtc().toIso8601String());
          }
          final rows = await query.order('logged_at', ascending: false);
          return rows.map(SymptomLogModel.fromJson).toList();
        },
        'Failed to load symptoms',
      );

  @override
  Future<SymptomLogModel> logSymptom({
    required String userId,
    required SymptomType type,
    required SymptomSeverity severity,
    required DateTime loggedAt,
    String? notes,
  }) =>
      supabaseCall(
        () async {
          final now = DateTime.now();
          final row = await _client
              .from(_table)
              .insert(
                SymptomLogModel(
                  id: '',
                  userId: userId,
                  type: type,
                  severity: severity,
                  loggedAt: loggedAt,
                  notes: notes,
                  createdAt: now,
                  updatedAt: now,
                ).toInsertJson(),
              )
              .select()
              .single();
          return SymptomLogModel.fromJson(row);
        },
        'Failed to log symptom',
      );

  @override
  Future<SymptomLogModel> updateSymptomLog({
    required String id,
    SymptomType? type,
    SymptomSeverity? severity,
    DateTime? loggedAt,
    String? notes,
  }) =>
      supabaseCall(
        () async {
          final updates = <String, dynamic>{
            if (type != null) 'symptom_type': type.name,
            if (severity != null) 'severity': severity.name,
            if (loggedAt != null)
              'logged_at': loggedAt.toUtc().toIso8601String(),
            if (notes != null) 'notes': _cleanNotes(notes),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          };
          final row = await _client
              .from(_table)
              .update(updates)
              .eq('id', id)
              .select()
              .single();
          return SymptomLogModel.fromJson(row);
        },
        'Failed to update symptom',
      );

  @override
  Future<void> deleteSymptomLog(String id) => supabaseCall(
        () => _client.from(_table).delete().eq('id', id),
        'Failed to delete symptom',
      );

  static String? _cleanNotes(String? notes) {
    final trimmed = notes?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
