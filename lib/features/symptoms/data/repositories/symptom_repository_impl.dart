import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/error_logger.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/error/guard.dart';
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
  }) =>
      guard(() async {
        // Opportunistically push anything queued; never fail a read for it.
        try {
          await _sync.flush();
        } catch (_) {}

        try {
          final remote = await _remote.getSymptomLogs(userId, from: from, to: to);
          if (from == null && to == null) {
            await _local.writeThroughFull(userId, remote);
          } else {
            await _local.upsertCache(remote);
          }
        } catch (_) {
          // Offline or server error → serve whatever the cache holds.
        }

        return _local.readCached(userId, from: from, to: to);
      });

  @override
  Future<Either<Failure, SymptomLogEntity>> logSymptom({
    required String userId,
    required SymptomType type,
    required SymptomSeverity severity,
    required DateTime loggedAt,
    String? notes,
  }) =>
      guard(() async {
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
        await _local.enqueueOp(
          operation: SymptomOp.create,
          targetId: localId,
          opId: localId,
          payload: {
            'user_id': userId,
            'symptom_type': type.name,
            'severity': severity.name,
            'logged_at': loggedAt.toUtc().toIso8601String(),
            'notes': notes,
          },
        );
        unawaited(_sync.flush());
        return entity;
      });

  @override
  Future<Either<Failure, SymptomLogEntity>> updateSymptomLog({
    required String id,
    SymptomType? type,
    SymptomSeverity? severity,
    DateTime? loggedAt,
    String? notes,
  }) async {
    // Not routed through guard(): the not-found branch below is an expected
    // outcome, not a fault, and guard() logs a stack for everything it catches.
    try {
      final current = _local.readOne(id);
      if (current == null) {
        // When a queued create syncs, the row's local id is swapped for the
        // server one. A caller still holding the old id lands here until it
        // reloads — silent on purpose.
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
      await _local.enqueueOp(
        operation: SymptomOp.update,
        targetId: id,
        payload: {
          if (type != null) 'symptom_type': type.name,
          if (severity != null) 'severity': severity.name,
          if (loggedAt != null) 'logged_at': loggedAt.toUtc().toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );
      unawaited(_sync.flush());
      return Right(updated);
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteSymptomLog(String id) =>
      guard(() async {
        await _local.deleteCache(id);
        if (id.startsWith('local-')) {
          // Never reached the server — just drop its queued ops.
          // ponytail: if this local row was synced (id swapped in cache) but the
          // caller still holds the local id (no reload yet), the server row is
          // orphaned and reappears on next load. Acceptable for a single-user v1;
          // upgrade path: reload the cubit when the sync service drains the queue.
          await _local.removeOpsFor(id);
        } else {
          await _local.enqueueOp(operation: SymptomOp.delete, targetId: id);
        }
        unawaited(_sync.flush());
      });
}
