import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/symptoms/data/datasources/symptom_local_datasource.dart';
import 'package:sheknows/features/symptoms/data/datasources/symptom_remote_datasource.dart';
import 'package:sheknows/features/symptoms/data/models/symptom_log_model.dart';
import 'package:sheknows/features/symptoms/data/services/symptom_sync_service.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/repositories/symptom_repository.dart';

/// Local-first repository. Every write lands in the local cache immediately and
/// is queued in the outbox; [SymptomSyncService] pushes the queue to Supabase
/// (now if online, on the next reconnect otherwise). Reads refresh from the
/// server when possible but always resolve from the cache, so the UI works
/// offline. A genuine local failure still surfaces as [UnknownFailure].
class SymptomRepositoryImpl implements SymptomRepository {
  SymptomRepositoryImpl(this._remote, this._local, this._sync);

  final SymptomRemoteDataSource _remote;
  final SymptomLocalDataSource _local;
  final SymptomSyncService _sync;

  @override
  Future<Either<Failure, List<SymptomLogEntity>>> getSymptomLogs(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      // Opportunistically push anything queued; never fail a read for it.
      try {
        await _sync.flush();
      } catch (_) {}

      try {
        final remote =
            await _remote.getSymptomLogs(userId, from: from, to: to);
        if (from == null && to == null) {
          await _local.writeThroughFull(userId, remote);
        } else {
          await _local.upsertCache(remote);
        }
      } catch (_) {
        // Offline or server error → serve whatever the cache holds.
      }

      return Right(_local.readCached(userId, from: from, to: to));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, SymptomLogEntity>> logSymptom({
    required String userId,
    required SymptomType type,
    required SymptomSeverity severity,
    required DateTime loggedAt,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final localId = 'local-${now.microsecondsSinceEpoch}';
      final entity = SymptomLogModel(
        id: localId,
        userId: userId,
        type: type,
        severity: severity,
        loggedAt: loggedAt,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );
      await _local.putCache(entity);
      await _local.enqueue({
        'op_id': localId,
        'operation': SymptomOp.create,
        'target_id': localId,
        'enqueued_at': now.microsecondsSinceEpoch,
        'payload': {
          'user_id': userId,
          'symptom_type': type.name,
          'severity': severity.name,
          'logged_at': loggedAt.toUtc().toIso8601String(),
          'notes': notes,
        },
      });
      unawaited(_sync.flush());
      return Right(entity);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, SymptomLogEntity>> updateSymptomLog({
    required String id,
    SymptomType? type,
    SymptomSeverity? severity,
    DateTime? loggedAt,
    String? notes,
  }) async {
    try {
      final current = _local.readOne(id);
      if (current == null) {
        return const Left(UnknownFailure());
      }
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
      await _local.putCache(updated);
      await _local.enqueue({
        'op_id': 'update-${DateTime.now().microsecondsSinceEpoch}',
        'operation': SymptomOp.update,
        'target_id': id,
        'enqueued_at': DateTime.now().microsecondsSinceEpoch,
        'payload': {
          if (type != null) 'symptom_type': type.name,
          if (severity != null) 'severity': severity.name,
          if (loggedAt != null) 'logged_at': loggedAt.toUtc().toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      });
      unawaited(_sync.flush());
      return Right(updated);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteSymptomLog(String id) async {
    try {
      await _local.deleteCache(id);
      if (id.startsWith('local-')) {
        // Never reached the server — just drop its queued ops.
        // ponytail: if this local row was synced (id swapped in cache) but the
        // caller still holds the local id (no reload yet), the server row is
        // orphaned and reappears on next load. Acceptable for a single-user v1;
        // upgrade path: reload the cubit when the sync service drains the queue.
        await _local.removeOpsFor(id);
      } else {
        await _local.enqueue({
          'op_id': 'delete-${DateTime.now().microsecondsSinceEpoch}',
          'operation': SymptomOp.delete,
          'target_id': id,
          'enqueued_at': DateTime.now().microsecondsSinceEpoch,
          'payload': null,
        });
      }
      unawaited(_sync.flush());
      return const Right(null);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
