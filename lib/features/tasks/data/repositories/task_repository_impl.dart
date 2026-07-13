import 'package:dartz/dartz.dart';
import 'package:supabase_flutter_starter_kit/core/error/exceptions.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/task_entity.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/tasks_page_result.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._remoteDataSource);

  final TaskRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, TasksPageResult>> getTasks({
    required String userId,
    DateTime? before,
    required int pageSize,
  }) async {
    try {
      final pageResult = await _remoteDataSource.getTasks(
        userId: userId,
        before: before,
        pageSize: pageSize,
      );
      return Right(pageResult);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String userId,
    required String title,
  }) async {
    try {
      final task = await _remoteDataSource.createTask(
        userId: userId,
        title: title,
      );
      return Right(task);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      final task = await _remoteDataSource.toggleTaskCompletion(
        taskId: taskId,
        isCompleted: isCompleted,
      );
      return Right(task);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _remoteDataSource.deleteTask(taskId);
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
