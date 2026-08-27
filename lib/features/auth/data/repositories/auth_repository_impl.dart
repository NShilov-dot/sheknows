import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/error/guard.dart';
import 'package:sheknows/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<UserEntity?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) =>
      guardAuth(
        () => _remoteDataSource.signInWithEmail(
          email: email,
          password: password,
        ),
      );

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      guardAuth(
        () => _remoteDataSource.signUpWithEmail(
          email: email,
          password: password,
        ),
      );

  @override
  Future<Either<Failure, void>> signInWithGoogle() =>
      guardAuth(() => _remoteDataSource.signInWithGoogle());

  @override
  Future<Either<Failure, void>> signOut() =>
      guardAuth(() => _remoteDataSource.signOut());

  @override
  Future<Either<Failure, void>> deleteAccount() =>
      guardAuth(() => _remoteDataSource.deleteAccount());

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() =>
      guard(() async => _remoteDataSource.getCurrentUser());
}
