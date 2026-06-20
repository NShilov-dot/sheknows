import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/task_entity.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/entities/tasks_page_result.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/usecases/task_usecases.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/presentation/cubit/tasks_state.dart';

class _MockGetTasks extends Mock implements GetTasksUseCase {}

class _MockCreateTask extends Mock implements CreateTaskUseCase {}

class _MockToggleTask extends Mock implements ToggleTaskUseCase {}

class _MockDeleteTask extends Mock implements DeleteTaskUseCase {}

void main() {
  late _MockGetTasks getTasks;
  late _MockCreateTask createTask;
  late _MockToggleTask toggleTask;
  late _MockDeleteTask deleteTask;

  const userId = 'user-1';
  final task = TaskEntity(
    id: 'task-1',
    userId: userId,
    title: 'Buy milk',
    isCompleted: false,
    createdAt: DateTime(2025, 6, 19),
    updatedAt: DateTime(2025, 6, 19),
  );
  final page = TasksPageResult(tasks: [task], hasMore: false);

  setUpAll(() {
    registerFallbackValue(const GetTasksParams(userId: userId));
    registerFallbackValue(const CreateTaskParams(userId: userId, title: 'Buy milk'));
    registerFallbackValue(const ToggleTaskParams(taskId: 'task-1', isCompleted: true));
    registerFallbackValue(const DeleteTaskParams('task-1'));
  });

  setUp(() {
    getTasks = _MockGetTasks();
    createTask = _MockCreateTask();
    toggleTask = _MockToggleTask();
    deleteTask = _MockDeleteTask();
  });

  TasksCubit buildCubit() => TasksCubit(
        getTasks: getTasks,
        createTask: createTask,
        toggleTask: toggleTask,
        deleteTask: deleteTask,
      );

  group('loadTasks', () {
    blocTest<TasksCubit, TasksState>(
      'emits [TasksLoading, TasksLoaded] on success',
      setUp: () {
        when(() => getTasks(any())).thenAnswer((_) async => Right(page));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadTasks(userId),
      expect: () => [
        const TasksLoading(),
        TasksLoaded(tasks: page.tasks, hasMore: page.hasMore),
      ],
    );

    blocTest<TasksCubit, TasksState>(
      'emits [TasksLoading, TasksError] on failure',
      setUp: () {
        when(() => getTasks(any()))
            .thenAnswer((_) async => const Left(ServerFailure('DB error')));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadTasks(userId),
      expect: () => [
        const TasksLoading(),
        const TasksError(ServerFailure('DB error')),
      ],
    );
  });

  group('addTask', () {
    blocTest<TasksCubit, TasksState>(
      'updates list locally without refetching on success',
      setUp: () {
        when(() => getTasks(any())).thenAnswer((_) async => Right(page));
        when(() => createTask(any())).thenAnswer((_) async => Right(task));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.loadTasks(userId);
        await cubit.addTask('Buy milk');
      },
      verify: (_) {
        verify(() => getTasks(any())).called(1);
        verify(() => createTask(any())).called(1);
      },
    );

    blocTest<TasksCubit, TasksState>(
      'reverts list and emits mutation failure on error',
      setUp: () {
        when(() => getTasks(any())).thenAnswer((_) async => Right(page));
        when(() => createTask(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Create failed')));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.loadTasks(userId);
        await cubit.addTask('Buy milk');
      },
      expect: () => [
        const TasksLoading(),
        TasksLoaded(tasks: page.tasks, hasMore: page.hasMore),
        isA<TasksLoaded>(),
        TasksLoaded(
          tasks: page.tasks,
          hasMore: page.hasMore,
          mutationFailure: const ServerFailure('Create failed'),
        ),
      ],
    );
  });
}
