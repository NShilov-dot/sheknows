import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/router/auth_refresh_listenable.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/auth/presentation/pages/login_page.dart';
import 'package:sheknows/features/auth/presentation/pages/register_page.dart';
import 'package:sheknows/features/home/presentation/pages/home_page.dart';
import 'package:sheknows/features/period/presentation/pages/period_tracker_page.dart';
import 'package:sheknows/features/splash/presentation/pages/splash_page.dart';
import 'package:sheknows/features/symptoms/presentation/pages/symptom_phase_page.dart';
import 'package:sheknows/features/symptoms/presentation/pages/symptom_trends_page.dart';
import 'package:sheknows/features/symptoms/presentation/pages/symptoms_page.dart';

@visibleForTesting
String? resolveAuthRedirect(AuthState authState, String location) {
  final isOnAuthPage = location == '/login' || location == '/register';
  final isOnSplash = location == '/splash';

  // Session restore in progress — keep users on splash.
  if (authState is AuthInitial) {
    return isOnSplash ? null : '/splash';
  }

  // In-progress sign-in / sign-out: do not yank the current screen away.
  if (authState is AuthLoading) {
    return null;
  }

  if (authState is AuthAuthenticated) {
    return isOnAuthPage || isOnSplash ? '/home' : null;
  }

  // Unauthenticated, AuthError, etc.
  if (isOnSplash) {
    return '/login';
  }
  return isOnAuthPage ? null : '/login';
}

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthRefreshListenable(_authBloc),
    redirect: (context, state) =>
        resolveAuthRedirect(_authBloc.state, state.matchedLocation),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
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
        path: '/cycle',
        builder: (context, state) => const PeriodTrackerPage(),
      ),
      GoRoute(
        path: '/symptoms',
        builder: (context, state) => const SymptomsPage(),
      ),
      GoRoute(
        path: '/symptom-trends',
        builder: (context, state) => const SymptomTrendsPage(),
      ),
      GoRoute(
        path: '/symptom-phases',
        builder: (context, state) => const SymptomPhasePage(),
      ),
    ],
  );
}
