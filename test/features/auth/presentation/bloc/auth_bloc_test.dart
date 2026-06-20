import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
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

void main() {
  late _MockGetAuthStateChanges getAuthStateChanges;
  late _MockGetCurrentUser getCurrentUser;
  late _MockSignInWithEmail signInWithEmail;
  late _MockSignUpWithEmail signUpWithEmail;
  late _MockSignInWithGoogle signInWithGoogle;
  late _MockSignOut signOut;

  const email = 'user@example.com';
  const password = 'secret123';
  const user = UserEntity(id: '1', email: email, emailConfirmed: true);

  setUpAll(() {
    registerFallbackValue(
      const SignInWithEmailParams(email: email, password: password),
    );
  });

  setUp(() {
    getAuthStateChanges = _MockGetAuthStateChanges();
    getCurrentUser = _MockGetCurrentUser();
    signInWithEmail = _MockSignInWithEmail();
    signUpWithEmail = _MockSignUpWithEmail();
    signInWithGoogle = _MockSignInWithGoogle();
    signOut = _MockSignOut();
  });

  AuthBloc buildBloc() => AuthBloc(
        getAuthStateChanges: getAuthStateChanges,
        getCurrentUser: getCurrentUser,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
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
}
