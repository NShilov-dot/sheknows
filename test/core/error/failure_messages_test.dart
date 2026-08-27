import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/error/failures.dart';

void main() {
  test('raw backend text never reaches the user', () {
    const leaky = ServerFailure(
      'new row violates row-level security policy for table "period_logs"',
    );
    expect(failureMessage(leaky), isNot(contains('row-level security')));
    expect(failureMessage(leaky), isNot(contains('period_logs')));
    expect(failureDebugMessage(leaky), contains('row-level security'));
  });

  test('Supabase auth text is replaced', () {
    const jwt = AuthFailure('JWT expired');
    expect(failureMessage(jwt), isNot(contains('JWT')));
  });

  test('our own validation copy passes through', () {
    const v = ValidationFailure('Enter a valid email address');
    expect(failureMessage(v), 'Enter a valid email address');
  });

  test('auth copy is flow-neutral — the scaffold is shared by sign-in and '
      'sign-up, so it must not name one of them', () {
    final copy = failureMessage(const AuthFailure()).toLowerCase();
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
      expect(failureMessage(f).trim(), isNotEmpty);
    }
  });
}
