import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/auth/presentation/utils/auth_validators.dart';

void main() {
  group('AuthValidators.email', () {
    test('returns error when empty', () {
      expect(AuthValidators.email(''), 'Email is required');
    });

    test('returns error for malformed address', () {
      expect(AuthValidators.email('not-an-email'), 'Enter a valid email address');
    });

    test('returns null for a valid address', () {
      expect(AuthValidators.email('user@example.com'), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('returns error when empty', () {
      expect(AuthValidators.password(''), 'Password is required');
    });

    test('allows any non-empty password for sign-in', () {
      expect(AuthValidators.password('123'), isNull);
    });

    test('rejects surrounding whitespace during registration', () {
      expect(
        AuthValidators.password(' secret123 ', forRegistration: true),
        'Password cannot start or end with spaces',
      );
    });

    test('returns error when shorter than the minimum length on registration', () {
      expect(
        AuthValidators.password('Ab1', forRegistration: true),
        'Password must be at least ${AuthValidators.minPasswordLength} characters',
      );
    });

    test('returns error when registration password lacks a letter or number', () {
      expect(
        AuthValidators.password('abcdefgh', forRegistration: true),
        'Password must include at least one letter and one number',
      );
      expect(
        AuthValidators.password('12345678', forRegistration: true),
        'Password must include at least one letter and one number',
      );
    });

    test('returns null for a valid registration password', () {
      expect(
        AuthValidators.password('secret123', forRegistration: true),
        isNull,
      );
    });
  });

  group('AuthValidators.confirmPassword', () {
    test('returns error when confirmation is empty', () {
      expect(AuthValidators.confirmPassword('', 'secret123'), 'Confirm your password');
    });

    test('returns error when passwords differ', () {
      expect(
        AuthValidators.confirmPassword('other', 'secret123'),
        'Passwords do not match',
      );
    });

    test('returns null when passwords match', () {
      expect(AuthValidators.confirmPassword('secret123', 'secret123'), isNull);
    });
  });
}
