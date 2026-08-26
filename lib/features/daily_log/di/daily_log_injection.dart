import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/features/daily_log/data/datasources/daily_log_remote_datasource.dart';
import 'package:sheknows/features/daily_log/data/repositories/daily_log_repository_impl.dart';
import 'package:sheknows/features/daily_log/domain/repositories/daily_log_repository.dart';
import 'package:sheknows/features/daily_log/domain/usecases/daily_log_usecases.dart';
import 'package:sheknows/features/daily_log/presentation/cubit/daily_log_cubit.dart';

void registerDailyLogDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<DailyLogRemoteDataSource>(
      () => DailyLogRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<DailyLogRepository>(
      () => DailyLogRepositoryImpl(sl<DailyLogRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetDailyLogUseCase(sl<DailyLogRepository>()))
    ..registerLazySingleton(() => SaveDailyLogUseCase(sl<DailyLogRepository>()))
    ..registerFactory(
      () => DailyLogCubit(
        getDailyLog: sl<GetDailyLogUseCase>(),
        saveDailyLog: sl<SaveDailyLogUseCase>(),
      ),
    );
}
