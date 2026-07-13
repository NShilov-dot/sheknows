import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/utils/auth_validators.dart';
import 'package:supabase_flutter_starter_kit/core/usecases/usecase.dart';
import 'package:supabase_flutter_starter_kit/features/auth/domain/usecases/auth_usecases.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_event.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required GetAuthStateChangesUseCase getAuthStateChanges,
    required GetCurrentUserUseCase getCurrentUser,
    required SignInWithEmailUseCase signInWithEmail,
    required SignUpWithEmailUseCase signUpWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignOutUseCase signOut,
    required DeleteAccountUseCase deleteAccount,
  })  : _getAuthStateChanges = getAuthStateChanges,
        _getCurrentUser = getCurrentUser,
        _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        _deleteAccount = deleteAccount,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthSignUpWithEmailRequested>(_onSignUpWithEmail);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthDeleteAccountRequested>(_onDeleteAccount);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  final GetAuthStateChangesUseCase _getAuthStateChanges;
  final GetCurrentUserUseCase _getCurrentUser;
  final SignInWithEmailUseCase _signInWithEmail;
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;

  StreamSubscription<dynamic>? _authSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    // Stay on AuthInitial while restoring the session so the router can show
    // a splash instead of flashing protected or auth screens.
    final currentUserResult = await _getCurrentUser(const NoParams());
    currentUserResult.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );

    await _authSubscription?.cancel();
    _authSubscription = _getAuthStateChanges().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      emit(AuthAuthenticated(user));
      return;
    }
    if (state is! AuthLoading) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    final validationError = _validateCredentials(
      event.email,
      event.password,
    );
    if (validationError != null) {
      emit(AuthError(validationError));
      return;
    }

    emit(const AuthLoading());
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    final validationError = _validateCredentials(
      event.email,
      event.password,
      forRegistration: true,
    );
    if (validationError != null) {
      emit(AuthError(validationError));
      return;
    }

    emit(const AuthLoading());
    final result = await _signUpWithEmail(
      SignUpWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) {
        if (user.emailConfirmed) {
          emit(AuthAuthenticated(user));
        } else {
          emit(
            const AuthUnauthenticated(
              message: 'Check your email to confirm your account.',
            ),
          );
        }
      },
    );
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) {},
    );
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signOut(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onDeleteAccount(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _deleteAccount(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(const AuthUnauthenticated());
  }

  ValidationFailure? _validateCredentials(
    String email,
    String password, {
    bool forRegistration = false,
  }) {
    final emailError = AuthValidators.email(email);
    if (emailError != null) {
      return ValidationFailure(emailError);
    }

    final passwordError = AuthValidators.password(
      password,
      forRegistration: forRegistration,
    );
    if (passwordError != null) {
      return ValidationFailure(passwordError);
    }

    return null;
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
