import 'package:dartz/dartz.dart';
import 'package:supabase_flutter_starter_kit/core/constants/pagination.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/core/usecases/usecase.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/task_entity.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/tasks_page_result.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/repositories/task_repository.dart';

class GetTasksParams {
  const GetTasksParams({
    required this.userId,
    this.before,
    this.pageSize = kTasksPageSize,
  });

  final String userId;

  /// Cursor: fetch tasks created strictly before this timestamp. Null loads
  /// the first (newest) page.
  final DateTime? before;
  final int pageSize;
}

class GetTasksUseCase implements UseCase<TasksPageResult, GetTasksParams> {
  GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, TasksPageResult>> call(GetTasksParams params) {
    return _repository.getTasks(
      userId: params.userId,
      before: params.before,
      pageSize: params.pageSize,
    );
  }
}

class CreateTaskParams {
  const CreateTaskParams({required this.userId, required this.title});

  final String userId;
  final String title;
}

class CreateTaskUseCase implements UseCase<TaskEntity, CreateTaskParams> {
  CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) {
    return _repository.createTask(userId: params.userId, title: params.title);
  }
}

class ToggleTaskParams {
  const ToggleTaskParams({required this.taskId, required this.isCompleted});

  final String taskId;
  final bool isCompleted;
}

class ToggleTaskUseCase implements UseCase<TaskEntity, ToggleTaskParams> {
  ToggleTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(ToggleTaskParams params) {
    return _repository.toggleTaskCompletion(
      taskId: params.taskId,
      isCompleted: params.isCompleted,
    );
  }
}

class DeleteTaskParams {
  const DeleteTaskParams(this.taskId);

  final String taskId;
}

class DeleteTaskUseCase implements UseCase<void, DeleteTaskParams> {
  DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) {
    return _repository.deleteTask(params.taskId);
  }
}
