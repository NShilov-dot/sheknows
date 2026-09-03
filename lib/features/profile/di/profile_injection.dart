import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/config/environment.dart';
import 'package:sheknows/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sheknows/features/profile/data/datasources/profile_remote_datasource_dev.dart';
import 'package:sheknows/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:sheknows/features/profile/domain/repositories/profile_repository.dart';
import 'package:sheknows/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:sheknows/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';

void registerProfileDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => Environment.devMode
          ? DevProfileRemoteDataSource()
          : ProfileRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepository>()))
    ..registerLazySingleton(
      () => UpdateProfileUseCase(sl<ProfileRepository>()),
    )
    // A singleton, not a factory: SupabaseApp holds the one instance for the
    // app's lifetime and resets it on sign-out.
    ..registerLazySingleton(
      () => ProfileCubit(
        getProfile: sl<GetProfileUseCase>(),
        updateProfile: sl<UpdateProfileUseCase>(),
      ),
    );
}
