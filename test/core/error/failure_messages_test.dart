import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/auth/presentation/utils/auth_validators.dart';
import 'package:sheknows/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('raw backend text never reaches the user', () {
    const leaky = ServerFailure(
      'new row violates row-level security policy for table "period_logs"',
    );
    expect(failureMessage(l10n, leaky), isNot(contains('row-level security')));
    expect(failureMessage(l10n, leaky), isNot(contains('period_logs')));
    expect(failureDebugMessage(leaky), contains('row-level security'));
  });

  test('Supabase auth text is replaced', () {
    const jwt = AuthFailure('JWT expired');
    expect(failureMessage(l10n, jwt), isNot(contains('JWT')));
  });

  test('a validation code is resolved to localized copy', () {
    final v = ValidationFailure(AuthValidationError.emailInvalid.name);
    expect(failureMessage(l10n, v), l10n.authValidationEmailInvalid);
  });

  test('a ValidationFailure message that is not one of our codes is never '
      'rendered — even if it reads like copy', () {
    const v = ValidationFailure('Enter a valid email address');
    expect(failureMessage(l10n, v), l10n.errorUnknown);
    expect(failureMessage(l10n, v), isNot(contains('valid email')));
  });

  test('auth copy is flow-neutral — the scaffold is shared by sign-in and '
      'sign-up, so it must not name one of them', () {
    final copy = failureMessage(l10n, const AuthFailure()).toLowerCase();
    expect(copy, isNot(contains('sign you in')));
    expect(copy, isNot(contains('sign in')));
    expect(copy, isNot(contains('sign up')));
  });

  test('every Failure subtype maps to non-empty user copy', () {
    for (final f in const <Failure>[
      AuthFailure(),
      ServerFailure(),
      NetworkFailure(),
      ValidationFailure(),
      UnknownFailure(),
    ]) {
      expect(failureMessage(l10n, f).trim(), isNotEmpty);
    }
  });
}
