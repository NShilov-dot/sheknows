import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/router/app_shell.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_event.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockPeriodCubit extends MockCubit<PeriodState> implements PeriodCubit {}

class _MockSymptomsCubit extends MockCubit<SymptomsState>
    implements SymptomsCubit {}

/// The shell is the one place the tabs, the shared cubits and the failure
/// snack bars meet, and it only exists inside a real [StatefulShellRoute] —
/// so it is exercised through one, with the tab pages stubbed to a word each.
void main() {
  const user = UserEntity(id: 'user-1', email: 'a@b.co', emailConfirmed: true);

  late _MockAuthBloc authBloc;
  late _MockPeriodCubit periodCubit;
  late _MockSymptomsCubit symptomsCubit;
  late GoRouter router;

  setUp(() {
    authBloc = _MockAuthBloc();
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthAuthenticated(user),
    );

    periodCubit = _MockPeriodCubit();
    whenListen(
      periodCubit,
      const Stream<PeriodState>.empty(),
      initialState: const PeriodInitial(),
    );
    when(() => periodCubit.load(any())).thenAnswer((_) async {});

    symptomsCubit = _MockSymptomsCubit();
    whenListen(
      symptomsCubit,
      const Stream<SymptomsState>.empty(),
      initialState: const SymptomsInitial(),
    );
    when(() => symptomsCubit.load(any())).thenAnswer((_) async {});

    // AppShell resolves its shared cubits through the service locator.
    sl
      ..registerFactory<PeriodCubit>(() => periodCubit)
      ..registerFactory<SymptomsCubit>(() => symptomsCubit);

    GoRoute page(String path, String label) => GoRoute(
          path: path,
          builder: (context, state) => Scaffold(body: Text(label)),
        );
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [page('/home', 'home page')]),
            StatefulShellBranch(routes: [page('/cycle', 'cycle page')]),
            StatefulShellBranch(routes: [page('/symptoms', 'symptoms page')]),
            StatefulShellBranch(routes: [page('/profile', 'profile page')]),
          ],
        ),
      ],
    );
  });

  tearDown(() async {
    router.dispose();
    await sl.reset();
  });

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(
          theme: AppTheme.dark,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loads both shared cubits for the signed-in user once',
      (tester) async {
    await pumpShell(tester);

    verify(() => periodCubit.load(user.id)).called(1);
    verify(() => symptomsCubit.load(user.id)).called(1);
  });

  testWidgets('shows the four tabs and switches branch on tap', (tester) async {
    await pumpShell(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('home page'), findsOneWidget);
    for (final label in ['Home', 'Cycle', 'Symptoms', 'Profile']) {
      expect(find.text(label), findsOneWidget, reason: '$label tab missing');
    }

    await tester.tap(find.text('Cycle'));
    await tester.pumpAndSettle();
    expect(find.text('cycle page'), findsOneWidget);
    expect(router.state.matchedLocation, '/cycle');

    // Switching back does not reload: the cubits belong to the shell, not to
    // a tab, so their data survives the round trip.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('home page'), findsOneWidget);
    verify(() => periodCubit.load(any())).called(1);
  });

  testWidgets('announces a period mutation failure from any tab once',
      (tester) async {
    const failure = ServerFailure('boom');
    final failed = PeriodLoaded(
      logs: const [],
      dayLogs: const [],
      displayedMonth: DateTime(2026, 9),
      stats: const CycleStats(periodCount: 0),
      mutationFailure: failure,
    );
    whenListen(
      periodCubit,
      Stream.fromIterable([failed, failed.copyWith(isLoading: true)]),
      initialState: const PeriodInitial(),
    );

    await pumpShell(tester);

    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(failureMessage(en, failure)), findsOneWidget);
  });
}
