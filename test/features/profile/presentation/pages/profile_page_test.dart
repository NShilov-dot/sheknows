import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_event.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/profile/domain/entities/profile_entity.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_state.dart';
import 'package:sheknows/features/profile/presentation/pages/profile_page.dart';
import 'package:sheknows/features/profile/presentation/widgets/edit_display_name_sheet.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

/// The page wires three actions to two blocs and one sheet. These drive each
/// from a tap, the way a user would, with both blocs mocked.
void main() {
  const user = UserEntity(
    id: 'user-1',
    email: 'anna@example.com',
    displayName: 'Anna',
    emailConfirmed: true,
  );
  const loaded =
      ProfileLoaded(ProfileEntity(id: 'user-1', displayName: 'Anna'));

  late _MockAuthBloc authBloc;
  late _MockProfileCubit profileCubit;

  setUp(() {
    authBloc = _MockAuthBloc();
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthAuthenticated(user),
    );
    profileCubit = _MockProfileCubit();
    when(() => profileCubit.loadProfile(any(), force: any(named: 'force')))
        .thenAnswer((_) async {});
    when(() => profileCubit.updateDisplayName(any())).thenAnswer((_) async {});
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Stream<ProfileState> profileStates = const Stream.empty(),
    ProfileState initial = loaded,
  }) async {
    whenListen(profileCubit, profileStates, initialState: initial);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loads the profile for the signed-in user on first build',
      (tester) async {
    await pumpPage(tester);
    verify(() => profileCubit.loadProfile(user.id)).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out the header and the three account rows', (tester) async {
    await pumpPage(tester);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('Go Premium'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });

  testWidgets('sign out dispatches to the auth bloc', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Sign out'));
    verify(() => authBloc.add(const AuthSignOutRequested())).called(1);
  });

  testWidgets('delete account asks first, then dispatches', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    verifyNever(() => authBloc.add(const AuthDeleteAccountRequested()));

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verify(() => authBloc.add(const AuthDeleteAccountRequested())).called(1);
  });

  testWidgets('the edit sheet hands the typed name to the cubit and closes',
      (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byTooltip('Edit name'));
    await tester.pumpAndSettle();
    expect(find.byType(EditDisplayNameSheet), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Anna K.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(() => profileCubit.updateDisplayName('Anna K.')).called(1);
    expect(find.byType(EditDisplayNameSheet), findsNothing);
  });

  testWidgets('announces a rejected edit in a snack bar', (tester) async {
    const failure = ServerFailure('boom');
    await pumpPage(
      tester,
      profileStates: Stream.fromIterable(const [
        ProfileLoaded(ProfileEntity(id: 'user-1', displayName: 'Anna K.'),
            isSaving: true),
        ProfileLoaded(ProfileEntity(id: 'user-1', displayName: 'Anna'),
            mutationFailure: failure),
      ]),
    );
    expect(find.byType(SnackBar), findsOneWidget);
    // Back on the stored name after the rollback.
    expect(find.text('Anna'), findsOneWidget);
  });
}
