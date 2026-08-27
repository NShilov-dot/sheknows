import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/auth/presentation/utils/auth_validators.dart';

void main() {
  group('AuthValidators.email', () {
    test('rejects an empty value', () {
      expect(AuthValidators.email(''), AuthValidationError.emailRequired);
    });

    test('rejects a malformed address', () {
      expect(
        AuthValidators.email('not-an-email'),
        AuthValidationError.emailInvalid,
      );
    });

    test('accepts a well-formed address', () {
      expect(AuthValidators.email('user@example.com'), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('rejects an empty value', () {
      expect(AuthValidators.password(''), AuthValidationError.passwordRequired);
    });

    test('sign-in only needs a non-empty value', () {
      expect(AuthValidators.password('123'), isNull);
    });

    test('registration rejects surrounding whitespace', () {
      expect(
        AuthValidators.password(' secret123 ', forRegistration: true),
        AuthValidationError.passwordWhitespace,
      );
    });

    test('registration rejects a short password', () {
      expect(
        AuthValidators.password('Ab1', forRegistration: true),
        AuthValidationError.passwordTooShort,
      );
    });

    test('registration requires a letter and a digit', () {
      expect(
        AuthValidators.password('abcdefgh', forRegistration: true),
        AuthValidationError.passwordWeak,
      );
      expect(
        AuthValidators.password('12345678', forRegistration: true),
        AuthValidationError.passwordWeak,
      );
    });

    test('registration accepts a compliant password', () {
      expect(
        AuthValidators.password('secret123', forRegistration: true),
        isNull,
      );
    });
  });

  group('AuthValidators.confirmPassword', () {
    test('rejects an empty confirmation', () {
      expect(
        AuthValidators.confirmPassword('', 'secret123'),
        AuthValidationError.confirmRequired,
      );
    });

    test('rejects a mismatch', () {
      expect(
        AuthValidators.confirmPassword('other', 'secret123'),
        AuthValidationError.confirmMismatch,
      );
    });

    test('accepts a match', () {
      expect(AuthValidators.confirmPassword('secret123', 'secret123'), isNull);
    });
  });
}
