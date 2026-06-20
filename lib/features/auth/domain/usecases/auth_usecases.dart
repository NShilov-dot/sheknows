import 'package:dartz/dartz.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/core/usecases/usecase.dart';
import 'package:supabase_flutter_starter_kit/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter_starter_kit/features/auth/domain/repositories/auth_repository.dart';

class GetAuthStateChangesUseCase {
  GetAuthStateChangesUseCase(this._repository);

  final AuthRepository _repository;

  Stream<UserEntity?> call() => _repository.authStateChanges;
}

class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}

class SignInWithEmailParams {
  const SignInWithEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class SignInWithEmailUseCase implements UseCase<UserEntity, SignInWithEmailParams> {
  SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) {
    return _repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignUpWithEmailParams {
  const SignUpWithEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class SignUpWithEmailUseCase implements UseCase<UserEntity, SignUpWithEmailParams> {
  SignUpWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) {
    return _repository.signUpWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithGoogleUseCase implements UseCase<void, NoParams> {
  SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}

class SignOutUseCase implements UseCase<void, NoParams> {
  SignOutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.signOut();
  }
}
