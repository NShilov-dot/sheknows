import 'package:equatable/equatable.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// A user-facing note the auth flow wants shown once, as a code — the copy is
/// picked at the presentation edge, which has a BuildContext.
enum AuthNotice { confirmEmail }

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.notice});

  final AuthNotice? notice;

  @override
  List<Object?> get props => [notice];
}

final class AuthError extends AuthState {
  const AuthError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
