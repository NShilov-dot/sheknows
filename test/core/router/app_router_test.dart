import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/router/app_router.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';

void main() {
  const user = UserEntity(
    id: 'user-1',
    email: 'a@b.co',
    emailConfirmed: true,
  );

  const authenticated = AuthAuthenticated(user);
  const unauthenticated = AuthUnauthenticated();

  const protectedRoutes = [
    '/home',
    '/cycle',
    '/symptoms',
    '/symptom-trends',
    '/symptom-phases',
  ];

  group('resolveAuthRedirect while the session is restoring', () {
    test('holds on splash', () {
      expect(resolveAuthRedirect(const AuthInitial(), '/splash'), isNull);
    });

    test('sends every other location to splash', () {
      for (final location in [...protectedRoutes, '/login', '/register']) {
        expect(
          resolveAuthRedirect(const AuthInitial(), location),
          '/splash',
          reason: 'restoring from $location should wait on splash',
        );
      }
    });
  });

  group('resolveAuthRedirect during an in-flight sign-in or sign-out', () {
    test('never redirects, so the current screen is not yanked away', () {
      for (final location in [...protectedRoutes, '/login', '/splash']) {
        expect(
          resolveAuthRedirect(const AuthLoading(), location),
          isNull,
          reason: '$location should be left alone while auth is in flight',
        );
      }
    });
  });

  group('resolveAuthRedirect when authenticated', () {
    test('bounces off the auth pages and splash to home', () {
      for (final location in ['/login', '/register', '/splash']) {
        expect(resolveAuthRedirect(authenticated, location), '/home');
      }
    });

    test('leaves the protected routes alone', () {
      for (final location in protectedRoutes) {
        expect(resolveAuthRedirect(authenticated, location), isNull);
      }
    });
  });

  group('resolveAuthRedirect when unauthenticated', () {
    test('sends splash and every protected route to login', () {
      for (final location in ['/splash', ...protectedRoutes]) {
        expect(resolveAuthRedirect(unauthenticated, location), '/login');
      }
    });

    test('leaves the auth pages alone so sign-up stays reachable', () {
      expect(resolveAuthRedirect(unauthenticated, '/login'), isNull);
      expect(resolveAuthRedirect(unauthenticated, '/register'), isNull);
    });

    test('a message on the state does not change routing', () {
      const withMessage = AuthUnauthenticated(notice: AuthNotice.confirmEmail);
      expect(resolveAuthRedirect(withMessage, '/register'), isNull);
      expect(resolveAuthRedirect(withMessage, '/home'), '/login');
    });
  });

  group('resolveAuthRedirect on an auth error', () {
    const errored = AuthError(ServerFailure('boom'));

    test('is treated as unauthenticated rather than stranding the user', () {
      expect(resolveAuthRedirect(errored, '/home'), '/login');
      expect(resolveAuthRedirect(errored, '/splash'), '/login');
    });

    test('keeps the user on the auth page so the error can be shown there', () {
      expect(resolveAuthRedirect(errored, '/login'), isNull);
      expect(resolveAuthRedirect(errored, '/register'), isNull);
    });
  });

  group('resolveAuthRedirect before onboarding has been seen', () {
    test('funnels an unauthenticated visitor to onboarding from anywhere', () {
      for (final location in [
        '/splash',
        '/login',
        '/register',
        ...protectedRoutes,
      ]) {
        expect(
          resolveAuthRedirect(unauthenticated, location,
              hasSeenOnboarding: false),
          '/onboarding',
          reason: '$location should show the value pitch first',
        );
      }
    });

    test('leaves the onboarding screen itself alone', () {
      expect(
        resolveAuthRedirect(unauthenticated, '/onboarding',
            hasSeenOnboarding: false),
        isNull,
      );
    });

    test('an authenticated session skips onboarding entirely', () {
      expect(
        resolveAuthRedirect(authenticated, '/onboarding',
            hasSeenOnboarding: false),
        '/home',
      );
      for (final location in protectedRoutes) {
        expect(
          resolveAuthRedirect(authenticated, location,
              hasSeenOnboarding: false),
          isNull,
        );
      }
    });

    test('still waits on splash while the session is restoring', () {
      expect(
        resolveAuthRedirect(const AuthInitial(), '/onboarding',
            hasSeenOnboarding: false),
        '/splash',
      );
    });
  });

  test('once onboarding is seen, its route falls through to login', () {
    expect(
      resolveAuthRedirect(unauthenticated, '/onboarding',
          hasSeenOnboarding: true),
      '/login',
    );
  });

  test('an unknown location is still guarded', () {
    expect(resolveAuthRedirect(unauthenticated, '/nope'), '/login');
    expect(resolveAuthRedirect(authenticated, '/nope'), isNull);
  });
}
