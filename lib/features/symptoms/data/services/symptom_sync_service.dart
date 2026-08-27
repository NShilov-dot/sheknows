import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sheknows/features/symptoms/data/datasources/symptom_local_datasource.dart';
import 'package:sheknows/features/symptoms/data/datasources/symptom_remote_datasource.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';

/// Replays the local outbox against Supabase. Runs on every reconnect and is
/// also flushed eagerly by the repository after each write and on load.
///
/// ponytail: last-write-wins, no cross-device conflict merge — correct for a
/// single-user personal log. Upgrade path if concurrent multi-device editing
/// becomes real: per-row version/updated_at compare-and-set before applying.
class SymptomSyncService {
  SymptomSyncService({
    required SymptomRemoteDataSource remote,
    required SymptomLocalDataSource local,
    required Connectivity connectivity,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity;

  final SymptomRemoteDataSource _remote;
  final SymptomLocalDataSource _local;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _flushing = false;

  /// Begins listening for connectivity changes. Idempotent.
  void start() {
    _subscription ??=
        _connectivity.onConnectivityChanged.listen((results) {
      if (_isOnline(results)) {
        flush();
      }
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Drains queued mutations in order. Stops at the first network/server error
  /// and leaves the rest for the next reconnect. Safe to call concurrently —
  /// overlapping calls are ignored.
  Future<void> flush() async {
    if (_flushing || !_local.hasPending) {
      return;
    }
    _flushing = true;
    // Maps a not-yet-synced local id to its server id within this pass.
    final remap = <String, String>{};
    try {
      for (final op in _local.pendingOps()) {
        try {
          await _apply(op, remap);
          await _local.dequeue(op['op_id'] as String);
        } catch (_) {
          break;
        }
      }
    } finally {
      _flushing = false;
    }
  }

  Future<void> _apply(
    Map<String, dynamic> op,
    Map<String, String> remap,
  ) async {
    final operation = op['operation'] as String;
    final rawTarget = op['target_id'] as String;
    final targetId = remap[rawTarget] ?? rawTarget;

    switch (operation) {
      case SymptomOp.create:
        final payload = _asJson(op['payload']);
        final saved = await _remote.logSymptom(
          userId: payload['user_id'] as String,
          type: symptomTypeFromName(payload['symptom_type'] as String?)!,
          severity: symptomSeverityFromName(payload['severity'] as String?)!,
          loggedAt: DateTime.parse(payload['logged_at'] as String).toLocal(),
          notes: payload['notes'] as String?,
        );
        remap[rawTarget] = saved.id;
        await _local.replaceCacheId(rawTarget, saved);
        await _local.retargetOps(rawTarget, saved.id);
      case SymptomOp.update:
        final payload = _asJson(op['payload']);
        final saved = await _remote.updateSymptomLog(
          id: targetId,
          type: symptomTypeFromName(payload['symptom_type'] as String?),
          severity: symptomSeverityFromName(payload['severity'] as String?),
          loggedAt: payload['logged_at'] == null
              ? null
              : DateTime.parse(payload['logged_at'] as String).toLocal(),
          notes: payload['notes'] as String?,
        );
        await _local.putCache(saved);
      case SymptomOp.delete:
        await _remote.deleteSymptomLog(targetId);
    }
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  static Map<String, dynamic> _asJson(dynamic raw) =>
      Map<String, dynamic>.from(raw as Map);
}
