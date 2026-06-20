import 'package:dartz/dartz.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/task_entity.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/tasks_page_result.dart';

abstract class TaskRepository {
  Future<Either<Failure, TasksPageResult>> getTasks({
    required String userId,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, TaskEntity>> createTask({
    required String userId,
    required String title,
  });

  Future<Either<Failure, TaskEntity>> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  });

  Future<Either<Failure, void>> deleteTask(String taskId);
}
