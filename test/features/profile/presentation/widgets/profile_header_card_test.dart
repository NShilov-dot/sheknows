import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/profile/domain/entities/profile_entity.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_state.dart';
import 'package:sheknows/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class _MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  // The narrowest phone still receiving OS updates (iPhone SE 1st gen).
  const narrow = Size(320, 568);

  const user = UserEntity(
    id: 'user-1',
    email: 'anna@example.com',
    emailConfirmed: true,
  );

  late _MockProfileCubit cubit;

  setUp(() => cubit = _MockProfileCubit());

  Future<void> pump(
    WidgetTester tester,
    ProfileState state, {
    UserEntity user = user,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = narrow;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    whenListen(cubit, const Stream<ProfileState>.empty(), initialState: state);

    await tester.pumpWidget(
      BlocProvider<ProfileCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ProfileHeaderCard(user: user),
            ),
          ),
        ),
      ),
    );
  }

  group('initials', () {
    test('take the first and last word, uppercased', () {
      expect(ProfileAvatar.initialsFor('anna karenina', 'a@b.co'), 'AK');
      expect(ProfileAvatar.initialsFor('Anna', 'a@b.co'), 'A');
      expect(ProfileAvatar.initialsFor('  Anna  Maria  Rey ', 'a@b.co'), 'AR');
    });

    test('fall back to the email without a name', () {
      expect(ProfileAvatar.initialsFor(null, 'zoe@b.co'), 'Z');
      expect(ProfileAvatar.initialsFor('   ', 'zoe@b.co'), 'Z');
    });
  });

  testWidgets('shows the stored name, its initials and the email', (t) async {
    await pump(
      t,
      const ProfileLoaded(ProfileEntity(id: 'user-1', displayName: 'Dev User')),
    );
    expect(t.takeException(), isNull);
    expect(find.text('Dev User'), findsOneWidget);
    expect(find.text('DU'), findsOneWidget);
    expect(find.text('anna@example.com'), findsOneWidget);
    expect(find.byTooltip('Edit name'), findsOneWidget);
  });

  testWidgets('invites a name when the row has none and neither does auth',
      (t) async {
    await pump(t, const ProfileLoaded(null));
    expect(find.text('Add your name'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('falls back to the auth metadata name while the row is empty',
      (t) async {
    await pump(
      t,
      const ProfileLoaded(null),
      user: const UserEntity(
        id: 'user-1',
        email: 'anna@example.com',
        displayName: 'Anna Google',
        emailConfirmed: true,
      ),
    );
    expect(find.text('Anna Google'), findsOneWidget);
    expect(find.text('Add your name'), findsNothing);
  });

  testWidgets('hides the edit action until the row is known', (t) async {
    await pump(t, const ProfileLoading());
    expect(find.byTooltip('Edit name'), findsNothing);
    expect(find.text('anna@example.com'), findsOneWidget);
  });

  testWidgets('flags an unconfirmed email', (t) async {
    await pump(
      t,
      const ProfileLoaded(null),
      user: const UserEntity(id: 'user-1', email: 'anna@example.com'),
    );
    expect(find.text('Email not confirmed yet'), findsOneWidget);
  });

  testWidgets('offers a retry when the row failed to load', (t) async {
    await pump(t, const ProfileError(ServerFailure('boom')));
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('does not overflow at 320dp with a long Russian name', (t) async {
    await pump(
      t,
      const ProfileLoaded(
        ProfileEntity(
          id: 'user-1',
          displayName: 'Александра Константинопольская',
        ),
      ),
      user: const UserEntity(
        id: 'user-1',
        email: 'aleksandra.konstantinopolskaya@example.com',
      ),
      locale: const Locale('ru'),
    );
    expect(t.takeException(), isNull);
  });
}
