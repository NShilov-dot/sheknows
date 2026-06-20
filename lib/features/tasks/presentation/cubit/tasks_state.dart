import 'package:equatable/equatable.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/task_entity.dart';

sealed class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

final class TasksInitial extends TasksState {
  const TasksInitial();
}

final class TasksLoading extends TasksState {
  const TasksLoading();
}

final class TasksLoaded extends TasksState {
  const TasksLoaded({
    required this.tasks,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.mutationFailure,
  });

  final List<TaskEntity> tasks;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? mutationFailure;

  TasksLoaded copyWith({
    List<TaskEntity>? tasks,
    bool? hasMore,
    bool? isLoadingMore,
    Failure? mutationFailure,
    bool clearMutationFailure = false,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      mutationFailure:
          clearMutationFailure ? null : (mutationFailure ?? this.mutationFailure),
    );
  }

  @override
  List<Object?> get props => [tasks, hasMore, isLoadingMore, mutationFailure];
}

final class TasksError extends TasksState {
  const TasksError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
