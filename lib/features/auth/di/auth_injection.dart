import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_starter_kit/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter_starter_kit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_flutter_starter_kit/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter_starter_kit/features/auth/domain/usecases/auth_usecases.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_bloc.dart';

void registerAuthDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetAuthStateChangesUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignInWithEmailUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignUpWithEmailUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignInWithGoogleUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()))
    ..registerFactory(
      () => AuthBloc(
        getAuthStateChanges: sl<GetAuthStateChangesUseCase>(),
        getCurrentUser: sl<GetCurrentUserUseCase>(),
        signInWithEmail: sl<SignInWithEmailUseCase>(),
        signUpWithEmail: sl<SignUpWithEmailUseCase>(),
        signInWithGoogle: sl<SignInWithGoogleUseCase>(),
        signOut: sl<SignOutUseCase>(),
      ),
    );
}
