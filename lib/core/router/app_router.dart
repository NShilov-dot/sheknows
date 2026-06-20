import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_state.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/pages/login_page.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/pages/register_page.dart';
import 'package:supabase_flutter_starter_kit/features/home/presentation/pages/home_page.dart';
import 'package:supabase_flutter_starter_kit/features/tasks/presentation/pages/tasks_page.dart';

enum _AuthRouteStatus { pending, authenticated, unauthenticated }

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthRefreshListenable(_authBloc),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final isOnAuthPage =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      if (authState is AuthAuthenticated) {
        return isOnAuthPage ? '/home' : null;
      }

      return isOnAuthPage ? null : '/login';
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TasksPage(),
      ),
    ],
  );
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._authBloc) {
    _subscription = _authBloc.stream.listen(_onAuthStateChanged);
  }

  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _subscription;
  _AuthRouteStatus _status = _AuthRouteStatus.pending;

  void _onAuthStateChanged(AuthState state) {
    if (state is AuthInitial || state is AuthLoading) {
      return;
    }

    final nextStatus = state is AuthAuthenticated
        ? _AuthRouteStatus.authenticated
        : _AuthRouteStatus.unauthenticated;

    if (_status == nextStatus) {
      return;
    }

    _status = nextStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
