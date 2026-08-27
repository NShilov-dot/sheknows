import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sheknows/features/symptoms/data/models/symptom_log_model.dart';

/// Outbox operation kinds. Persisted by name, so keep stable.
class SymptomOp {
  static const create = 'create';
  static const update = 'update';
  static const delete = 'delete';
}

/// Opens (and names) the Hive boxes this feature needs. Called once during
/// app bootstrap, before DI resolves [SymptomLocalDataSource].
class SymptomsHive {
  const SymptomsHive._();

  static const cacheBoxName = 'symptom_cache';
  static const outboxBoxName = 'symptom_outbox';

  static Future<void> openBoxes() async {
    await Hive.openBox<Map>(cacheBoxName);
    await Hive.openBox<Map>(outboxBoxName);
  }
}

/// Local-first store backing the symptoms feature: a read-model [cache] keyed
/// by log id and an [outbox] queue of un-synced mutations. Everything is stored
/// as `Map<String, dynamic>` produced by [SymptomLogModel.toCacheJson]; Hive
/// hands maps back as `Map<dynamic, dynamic>`, so reads cast once here.
class SymptomLocalDataSource {
  SymptomLocalDataSource(this._cache, this._outbox);

  final Box<Map> _cache;
  final Box<Map> _outbox;

  // -- Cache ---------------------------------------------------------------

  /// Cached logs for [userId], newest first, optionally bounded to `[from,to]`.
  List<SymptomLogModel> readCached(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) {
    final result = <SymptomLogModel>[];
    for (final raw in _cache.values) {
      final json = _asJson(raw);
      if (json['user_id'] != userId) {
        continue;
      }
      final model = SymptomLogModel.fromJson(json);
      if (from != null && model.loggedAt.isBefore(from)) {
        continue;
      }
      if (to != null && model.loggedAt.isAfter(to)) {
        continue;
      }
      result.add(model);
    }
    result.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return result;
  }

  /// The cached row for [id], or null when it isn't cached.
  SymptomLogModel? readOne(String id) {
    final raw = _cache.get(id);
    return raw == null ? null : SymptomLogModel.fromJson(_asJson(raw));
  }

  Future<void> putCache(SymptomLogModel model) =>
      _cache.put(model.id, model.toCacheJson());

  Future<void> deleteCache(String id) => _cache.delete(id);

  /// Swaps a locally-created row's key for its server-assigned one.
  Future<void> replaceCacheId(String localId, SymptomLogModel saved) async {
    await _cache.delete(localId);
    await _cache.put(saved.id, saved.toCacheJson());
  }

  /// Reconciles the cache after a full remote read: replaces every
  /// server-owned row for [userId] with [remote], while keeping local
  /// (not-yet-synced) rows whose ids are still in the outbox.
  Future<void> writeThroughFull(
    String userId,
    List<SymptomLogModel> remote,
  ) async {
    final pendingIds = pendingLocalIds();
    final stale = <dynamic>[];
    for (final key in _cache.keys) {
      final json = _asJson(_cache.get(key)!);
      if (json['user_id'] == userId && !pendingIds.contains(json['id'])) {
        stale.add(key);
      }
    }
    await _cache.deleteAll(stale);
    for (final model in remote) {
      await _cache.put(model.id, model.toCacheJson());
    }
  }

  /// Upserts remote rows into the cache without pruning (used for ranged reads
  /// where we can't safely tell which rows fall outside the window).
  Future<void> upsertCache(List<SymptomLogModel> models) async {
    for (final model in models) {
      await _cache.put(model.id, model.toCacheJson());
    }
  }

  // -- Outbox --------------------------------------------------------------

  /// Queued mutations, oldest first (replay order).
  List<Map<String, dynamic>> pendingOps() {
    final ops = _outbox.values.map(_asJson).toList()
      ..sort((a, b) =>
          (a['enqueued_at'] as int).compareTo(b['enqueued_at'] as int));
    return ops;
  }

  Set<String> pendingLocalIds() {
    final ids = <String>{};
    for (final raw in _outbox.values) {
      final op = _asJson(raw);
      if (op['operation'] == SymptomOp.create) {
        ids.add(op['target_id'] as String);
      }
    }
    return ids;
  }

  Future<void> enqueue(Map<String, dynamic> op) =>
      _outbox.put(op['op_id'], op);

  Future<void> dequeue(String opId) => _outbox.delete(opId);

  /// Drops every queued op targeting [targetId] (used when a not-yet-synced
  /// local row is deleted — there's nothing on the server to reconcile).
  Future<void> removeOpsFor(String targetId) async {
    final doomed = <dynamic>[];
    for (final key in _outbox.keys) {
      final op = _asJson(_outbox.get(key)!);
      if (op['target_id'] == targetId) {
        doomed.add(key);
      }
    }
    await _outbox.deleteAll(doomed);
  }

  /// Rewrites any queued op still targeting [localId] to use [realId] after a
  /// create syncs, so a follow-up edit/delete lands on the real row.
  Future<void> retargetOps(String localId, String realId) async {
    for (final key in _outbox.keys) {
      final op = _asJson(_outbox.get(key)!);
      if (op['target_id'] == localId) {
        op['target_id'] = realId;
        await _outbox.put(key, op);
      }
    }
  }

  bool get hasPending => _outbox.isNotEmpty;

  static Map<String, dynamic> _asJson(Map raw) =>
      Map<String, dynamic>.from(raw);
}
