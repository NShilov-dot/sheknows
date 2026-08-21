import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_starter_kit/features/period/data/datasources/period_remote_datasource.dart';
import 'package:supabase_flutter_starter_kit/features/period/data/repositories/period_repository_impl.dart';
import 'package:supabase_flutter_starter_kit/features/period/domain/entities/cycle_stats.dart';
import 'package:supabase_flutter_starter_kit/features/period/domain/repositories/period_repository.dart';
import 'package:supabase_flutter_starter_kit/features/period/domain/usecases/period_usecases.dart';
import 'package:supabase_flutter_starter_kit/features/period/presentation/cubit/period_cubit.dart';

void registerPeriodDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<PeriodRemoteDataSource>(
      () => PeriodRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<PeriodRepository>(
      () => PeriodRepositoryImpl(sl<PeriodRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetPeriodLogsUseCase(sl<PeriodRepository>()))
    ..registerLazySingleton(() => LogPeriodStartUseCase(sl<PeriodRepository>()))
    ..registerLazySingleton(
      () => UpdatePeriodLogUseCase(sl<PeriodRepository>()),
    )
    ..registerLazySingleton(() => DeletePeriodLogUseCase(sl<PeriodRepository>()))
    ..registerLazySingleton<CycleStatsCalculator>(
      () => const CycleStatsCalculator(),
    )
    ..registerFactory(
      () => PeriodCubit(
        getPeriodLogs: sl<GetPeriodLogsUseCase>(),
        logPeriodStart: sl<LogPeriodStartUseCase>(),
        updatePeriodLog: sl<UpdatePeriodLogUseCase>(),
        deletePeriodLog: sl<DeletePeriodLogUseCase>(),
        statsCalculator: sl<CycleStatsCalculator>(),
      ),
    );
}
