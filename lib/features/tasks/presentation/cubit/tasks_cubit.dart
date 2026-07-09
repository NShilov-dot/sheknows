import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_starter_kit/core/constants/pagination.dart';
import 'package:supabase_flutter_starter_kit/core/constants/tasks.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/task_entity.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/usecases/task_usecases.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/presentation/cubit/tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit({
    required GetTasksUseCase getTasks,
    required CreateTaskUseCase createTask,
    required ToggleTaskUseCase toggleTask,
    required DeleteTaskUseCase deleteTask,
  })  : _getTasks = getTasks,
        _createTask = createTask,
        _toggleTask = toggleTask,
        _deleteTask = deleteTask,
        super(const TasksInitial());

  final GetTasksUseCase _getTasks;
  final CreateTaskUseCase _createTask;
  final ToggleTaskUseCase _toggleTask;
  final DeleteTaskUseCase _deleteTask;

  String? _userId;
  int _currentPage = 0;
  bool _hasMore = false;

  Future<void> loadTasks(String userId) async {
    _userId = userId;
    _currentPage = 0;
    emit(const TasksLoading());
    final result = await _getTasks(
      GetTasksParams(userId: userId, page: 0, pageSize: kTasksPageSize),
    );
    result.fold(
      (failure) => emit(TasksError(failure)),
      (page) {
        _hasMore = page.hasMore;
        emit(TasksLoaded(tasks: page.tasks, hasMore: page.hasMore));
      },
    );
  }

  Future<void> loadMore() async {
    final userId = _userId;
    final current = _loadedState;
    if (userId == null || current == null || !_hasMore || current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, clearMutationFailure: true));
    final nextPage = _currentPage + 1;
    final result = await _getTasks(
      GetTasksParams(userId: userId, page: nextPage, pageSize: kTasksPageSize),
    );
    result.fold(
      (failure) => emit(
        current.copyWith(
          isLoadingMore: false,
          mutationFailure: failure,
        ),
      ),
      (page) {
        _currentPage = nextPage;
        _hasMore = page.hasMore;
        emit(
          TasksLoaded(
            tasks: [...current.tasks, ...page.tasks],
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }

  Future<void> addTask(String title) async {
    final userId = _userId;
    final trimmed = title.trim();
    if (userId == null ||
        trimmed.isEmpty ||
        trimmed.length > kTaskTitleMaxLength) {
      return;
    }

    final snapshot = _loadedState;
    if (snapshot == null) {
      return;
    }

    final optimisticId = 'pending-${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = TaskEntity(
      id: optimisticId,
      userId: userId,
      title: trimmed,
      isCompleted: false,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    emit(
      snapshot.copyWith(
        tasks: [optimistic, ...snapshot.tasks],
        clearMutationFailure: true,
      ),
    );

    final result = await _createTask(
      CreateTaskParams(userId: userId, title: trimmed),
    );
    result.fold(
      (failure) => _emitMutationFailure(snapshot, failure),
      (task) {
        final current = _loadedState ?? snapshot;
        final tasks = current.tasks
            .map((item) => item.id == optimisticId ? task : item)
            .toList();
        emit(current.copyWith(tasks: tasks, clearMutationFailure: true));
      },
    );
  }

  Future<void> toggleTask(String taskId, bool isCompleted) async {
    final snapshot = _loadedState;
    if (snapshot == null) {
      return;
    }

    final updatedTasks = snapshot.tasks.map((task) {
      if (task.id == taskId) {
        return TaskEntity(
          id: task.id,
          userId: task.userId,
          title: task.title,
          isCompleted: isCompleted,
          createdAt: task.createdAt,
          updatedAt: DateTime.now().toUtc(),
        );
      }
      return task;
    }).toList();

    emit(snapshot.copyWith(tasks: updatedTasks, clearMutationFailure: true));

    final result = await _toggleTask(
      ToggleTaskParams(taskId: taskId, isCompleted: isCompleted),
    );
    result.fold(
      (failure) => _emitMutationFailure(snapshot, failure),
      (task) {
        final current = _loadedState ?? snapshot;
        final tasks = current.tasks
            .map((item) => item.id == taskId ? task : item)
            .toList();
        emit(current.copyWith(tasks: tasks, clearMutationFailure: true));
      },
    );
  }

  Future<void> removeTask(String taskId) async {
    final snapshot = _loadedState;
    if (snapshot == null) {
      return;
    }

    final updatedTasks =
        snapshot.tasks.where((task) => task.id != taskId).toList();
    emit(snapshot.copyWith(tasks: updatedTasks, clearMutationFailure: true));

    final result = await _deleteTask(DeleteTaskParams(taskId));
    result.fold(
      (failure) => _emitMutationFailure(snapshot, failure),
      (_) {},
    );
  }

  void _emitMutationFailure(TasksLoaded snapshot, Failure failure) {
    emit(snapshot.copyWith(mutationFailure: failure));
  }

  TasksLoaded? get _loadedState {
    final current = state;
    return current is TasksLoaded ? current : null;
  }
}
