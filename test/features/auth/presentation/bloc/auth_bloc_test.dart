import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/core/usecases/usecase.dart';
import 'package:supabase_flutter_starter_kit/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter_starter_kit/features/auth/domain/usecases/auth_usecases.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_event.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_state.dart';

class _MockGetAuthStateChanges extends Mock implements GetAuthStateChangesUseCase {}

class _MockGetCurrentUser extends Mock implements GetCurrentUserUseCase {}

class _MockSignInWithEmail extends Mock implements SignInWithEmailUseCase {}

class _MockSignUpWithEmail extends Mock implements SignUpWithEmailUseCase {}

class _MockSignInWithGoogle extends Mock implements SignInWithGoogleUseCase {}

class _MockSignOut extends Mock implements SignOutUseCase {}

class _MockDeleteAccount extends Mock implements DeleteAccountUseCase {}

void main() {
  late _MockGetAuthStateChanges getAuthStateChanges;
  late _MockGetCurrentUser getCurrentUser;
  late _MockSignInWithEmail signInWithEmail;
  late _MockSignUpWithEmail signUpWithEmail;
  late _MockSignInWithGoogle signInWithGoogle;
  late _MockSignOut signOut;
  late _MockDeleteAccount deleteAccount;

  const email = 'user@example.com';
  const password = 'secret123';
  const user = UserEntity(id: '1', email: email, emailConfirmed: true);

  setUpAll(() {
    registerFallbackValue(
      const SignInWithEmailParams(email: email, password: password),
    );
    registerFallbackValue(
      const SignUpWithEmailParams(email: email, password: password),
    );
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getAuthStateChanges = _MockGetAuthStateChanges();
    getCurrentUser = _MockGetCurrentUser();
    signInWithEmail = _MockSignInWithEmail();
    signUpWithEmail = _MockSignUpWithEmail();
    signInWithGoogle = _MockSignInWithGoogle();
    signOut = _MockSignOut();
    deleteAccount = _MockDeleteAccount();
  });

  AuthBloc buildBloc() => AuthBloc(
        getAuthStateChanges: getAuthStateChanges,
        getCurrentUser: getCurrentUser,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
        deleteAccount: deleteAccount,
      );

  group('AuthSignInWithEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      setUp: () {
        when(() => signInWithEmail(any()))
            .thenAnswer((_) async => const Right(user));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AuthSignInWithEmailRequested(email: email, password: password),
      ),
      expect: () => const [AuthLoading(), AuthAuthenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      setUp: () {
        when(() => signInWithEmail(any()))
            .thenAnswer((_) async => const Left(AuthFailure('Invalid login')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AuthSignInWithEmailRequested(email: email, password: password),
      ),
      expect: () => const [AuthLoading(), AuthError(AuthFailure('Invalid login'))],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] without calling the use case when validation fails',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AuthSignInWithEmailRequested(email: 'invalid', password: password),
      ),
      expect: () => [isA<AuthError>()],
      verify: (_) => verifyNever(() => signInWithEmail(any())),
    );
  });

  group('AuthSignUpWithEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      setUp: () {
        when(() => signUpWithEmail(any()))
            .thenAnswer((_) async => const Right(user));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AuthSignUpWithEmailRequested(email: email, password: password),
      ),
      expect: () => const [AuthLoading(), AuthAuthenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] without calling the use case for a weak password',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AuthSignUpWithEmailRequested(email: email, password: 'short'),
      ),
      expect: () => [isA<AuthError>()],
      verify: (_) => verifyNever(() => signUpWithEmail(any())),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthError] without calling the use case for surrounding spaces',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AuthSignUpWithEmailRequested(
          email: email,
          password: ' secret123 ',
        ),
      ),
      expect: () => [isA<AuthError>()],
      verify: (_) => verifyNever(() => signUpWithEmail(any())),
    );
  });

  group('AuthDeleteAccountRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on success',
      setUp: () {
        when(() => deleteAccount(any()))
            .thenAnswer((_) async => const Right(null));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthDeleteAccountRequested()),
      expect: () => const [AuthLoading(), AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      setUp: () {
        when(() => deleteAccount(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Delete failed')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthDeleteAccountRequested()),
      expect: () =>
          const [AuthLoading(), AuthError(ServerFailure('Delete failed'))],
    );
  });
}
