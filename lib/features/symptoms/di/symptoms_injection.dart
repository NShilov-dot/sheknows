import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/config/environment.dart';
import 'package:sheknows/features/symptoms/data/datasources/symptom_local_datasource.dart';
import 'package:sheknows/features/symptoms/data/datasources/symptom_remote_datasource.dart';
import 'package:sheknows/features/symptoms/data/datasources/symptom_remote_datasource_dev.dart';
import 'package:sheknows/features/period/domain/usecases/period_usecases.dart';
import 'package:sheknows/features/symptoms/data/repositories/symptom_repository_impl.dart';
import 'package:sheknows/features/symptoms/data/services/symptom_phase_analyzer.dart';
import 'package:sheknows/features/symptoms/data/services/symptom_sync_service.dart';
import 'package:sheknows/features/symptoms/domain/repositories/symptom_repository.dart';
import 'package:sheknows/features/symptoms/domain/usecases/symptom_usecases.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';

/// Registers the symptoms feature. The Hive boxes must already be open
/// (see `SymptomsHive.openBoxes()` in `main.dart`) so they resolve
/// synchronously here.
void registerSymptomsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<SymptomRemoteDataSource>(
      () => Environment.devMode
          ? DevSymptomRemoteDataSource()
          : SymptomRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<SymptomLocalDataSource>(
      () => SymptomLocalDataSource(
        Hive.box<Map>(SymptomsHive.cacheBoxName),
        Hive.box<Map>(SymptomsHive.outboxBoxName),
      ),
    )
    ..registerLazySingleton<SymptomSyncService>(
      () => SymptomSyncService(
        remote: sl<SymptomRemoteDataSource>(),
        local: sl<SymptomLocalDataSource>(),
        connectivity: Connectivity(),
      ),
    )
    ..registerLazySingleton<SymptomRepository>(
      () => SymptomRepositoryImpl(
        sl<SymptomRemoteDataSource>(),
        sl<SymptomLocalDataSource>(),
        sl<SymptomSyncService>(),
      ),
    )
    ..registerLazySingleton(() => GetSymptomLogsUseCase(sl<SymptomRepository>()))
    ..registerLazySingleton(() => LogSymptomUseCase(sl<SymptomRepository>()))
    ..registerLazySingleton(
      () => UpdateSymptomLogUseCase(sl<SymptomRepository>()),
    )
    ..registerLazySingleton(
      () => DeleteSymptomLogUseCase(sl<SymptomRepository>()),
    )
    ..registerLazySingleton<SymptomPhaseAnalyzer>(
      () => const SymptomPhaseAnalyzer(),
    )
    ..registerFactory(
      () => SymptomsCubit(
        getSymptomLogs: sl<GetSymptomLogsUseCase>(),
        logSymptom: sl<LogSymptomUseCase>(),
        updateSymptomLog: sl<UpdateSymptomLogUseCase>(),
        deleteSymptomLog: sl<DeleteSymptomLogUseCase>(),
      ),
    )
    ..registerFactory(
      () => SymptomPhaseCubit(
        getSymptomLogs: sl<GetSymptomLogsUseCase>(),
        getPeriodLogs: sl<GetPeriodLogsUseCase>(),
        analyzer: sl<SymptomPhaseAnalyzer>(),
      ),
    );
}
