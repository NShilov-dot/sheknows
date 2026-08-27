import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';

/// Holds a screen back until the signed-in user's id is known, then hands it
/// to [builder].
///
/// Every data-backed screen needs the same three lines — select the id off
/// [AuthBloc], show a spinner while it is null, build once it isn't — and the
/// id is what its cubit loads with, so the screen cannot be built without it.
/// The router already keeps unauthenticated users out; the null window is the
/// frame between landing on the route and auth resolving.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.builder});

  final Widget Function(BuildContext context, String userId) builder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, String?>(
      selector: (state) => state is AuthAuthenticated ? state.user.id : null,
      builder: (context, userId) => userId == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : builder(context, userId),
    );
  }
}
