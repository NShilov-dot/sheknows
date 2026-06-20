import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/repositories/task_repository.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/domain/usecases/task_usecases.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/presentation/cubit/tasks_cubit.dart';

void registerTaskDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(sl<TaskRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetTasksUseCase(sl<TaskRepository>()))
    ..registerLazySingleton(() => CreateTaskUseCase(sl<TaskRepository>()))
    ..registerLazySingleton(() => ToggleTaskUseCase(sl<TaskRepository>()))
    ..registerLazySingleton(() => DeleteTaskUseCase(sl<TaskRepository>()))
    ..registerFactory(
      () => TasksCubit(
        getTasks: sl<GetTasksUseCase>(),
        createTask: sl<CreateTaskUseCase>(),
        toggleTask: sl<ToggleTaskUseCase>(),
        deleteTask: sl<DeleteTaskUseCase>(),
      ),
    );
}
