import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_starter_kit/core/error/exceptions.dart' as app_exceptions;
import 'package:supabase_flutter_starter_kit/features/tasks/data/models/task_model.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/tasks_page_result.dart';

abstract class TaskRemoteDataSource {
  Future<TasksPageResult> getTasks({
    required String userId,
    DateTime? before,
    required int pageSize,
  });

  Future<TaskModel> createTask({
    required String userId,
    required String title,
  });

  Future<TaskModel> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  });

  Future<void> deleteTask(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'tasks';

  @override
  Future<TasksPageResult> getTasks({
    required String userId,
    DateTime? before,
    required int pageSize,
  }) async {
    try {
      // Keyset pagination: fetch the page of rows older than `before` instead
      // of a numeric offset, so inserts/deletes at the head can't shift the
      // window and cause duplicate or skipped rows. Uses the
      // (user_id, created_at desc) index. Fetch one extra row to detect
      // `hasMore`, then trim it.
      final base = _client.from(_table).select().eq('user_id', userId);
      // ponytail: keys on created_at only. Two tasks with the exact same
      // microsecond timestamp straddling a page boundary could skip one row;
      // upgrade to a (created_at, id) composite cursor if that ever matters.
      final filtered = before == null
          ? base
          : base.lt('created_at', before.toUtc().toIso8601String());
      final rows = await filtered
          .order('created_at', ascending: false)
          .limit(pageSize + 1);
      final hasMore = rows.length > pageSize;
      final pageRows = hasMore ? rows.sublist(0, pageSize) : rows;
      return TasksPageResult(
        tasks: pageRows.map(TaskModel.fromJson).toList(),
        hasMore: hasMore,
      );
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to load tasks');
    }
  }

  @override
  Future<TaskModel> createTask({
    required String userId,
    required String title,
  }) async {
    try {
      final row = await _client
          .from(_table)
          .insert({'user_id': userId, 'title': title.trim()})
          .select()
          .single();
      return TaskModel.fromJson(row);
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to create task');
    }
  }

  @override
  Future<TaskModel> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      final row = await _client
          .from(_table)
          .update({
            'is_completed': isCompleted,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', taskId)
          .select()
          .single();
      return TaskModel.fromJson(row);
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to update task');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _client.from(_table).delete().eq('id', taskId);
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to delete task');
    }
  }
}
