import 'package:sheknows/core/error/exceptions.dart' as app_exceptions;
import 'package:sheknows/features/symptoms/data/datasources/symptom_remote_datasource.dart';
import 'package:sheknows/features/symptoms/data/models/symptom_log_model.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';

/// DEV_MODE symptom store: in-memory, no Supabase. Seeded with a few recent
/// entries so the list has something to render. Data resets on every restart.
class DevSymptomRemoteDataSource implements SymptomRemoteDataSource {
  DevSymptomRemoteDataSource() {
    _seed();
  }

  final List<SymptomLogModel> _logs = [];
  int _seq = 0;

  String _id() => 'dev-${_seq++}';

  void _seed() {
    final now = DateTime.now();
    final samples = <(SymptomType, SymptomSeverity, Duration)>[
      (SymptomType.cramps, SymptomSeverity.moderate, const Duration(hours: 3)),
      (SymptomType.headache, SymptomSeverity.mild, const Duration(days: 1)),
      (SymptomType.fatigue, SymptomSeverity.severe, const Duration(days: 2)),
    ];
    for (final (type, severity, ago) in samples) {
      final at = now.subtract(ago);
      _logs.add(
        SymptomLogModel(
          id: _id(),
          userId: 'dev-user',
          type: type,
          severity: severity,
          loggedAt: at,
          createdAt: at,
          updatedAt: at,
        ),
      );
    }
  }

  @override
  Future<List<SymptomLogModel>> getSymptomLogs(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    return _logs
        .where((log) => from == null || !log.loggedAt.isBefore(from))
        .where((log) => to == null || !log.loggedAt.isAfter(to))
        .toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
  }

  @override
  Future<SymptomLogModel> logSymptom({
    required String userId,
    required SymptomType type,
    required SymptomSeverity severity,
    required DateTime loggedAt,
    String? notes,
  }) async {
    final now = DateTime.now();
    final log = SymptomLogModel(
      id: _id(),
      userId: userId,
      type: type,
      severity: severity,
      loggedAt: loggedAt,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    _logs.add(log);
    return log;
  }

  @override
  Future<SymptomLogModel> updateSymptomLog({
    required String id,
    SymptomType? type,
    SymptomSeverity? severity,
    DateTime? loggedAt,
    String? notes,
  }) async {
    final index = _logs.indexWhere((log) => log.id == id);
    if (index == -1) {
      throw const app_exceptions.ServerException('Symptom not found');
    }
    final current = _logs[index];
    final updated = SymptomLogModel(
      id: current.id,
      userId: current.userId,
      type: type ?? current.type,
      severity: severity ?? current.severity,
      loggedAt: loggedAt ?? current.loggedAt,
      notes: notes ?? current.notes,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    _logs[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteSymptomLog(String id) async {
    _logs.removeWhere((log) => log.id == id);
  }
}
