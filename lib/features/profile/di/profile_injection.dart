import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_starter_kit/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:supabase_flutter_starter_kit/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:supabase_flutter_starter_kit/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter_starter_kit/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:supabase_flutter_starter_kit/features/profile/presentation/cubit/profile_cubit.dart';

void registerProfileDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepository>()))
    ..registerLazySingleton(
      () => ProfileCubit(getProfile: sl<GetProfileUseCase>()),
    );
}
