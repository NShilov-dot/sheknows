import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/utils/auth_validators.dart';

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

    test('returns error when shorter than the minimum length', () {
      expect(
        AuthValidators.password('123'),
        'Password must be at least ${AuthValidators.minPasswordLength} characters',
      );
    });

    test('rejects surrounding whitespace during registration', () {
      expect(
        AuthValidators.password(' secret123 ', forRegistration: true),
        'Password cannot start or end with spaces',
      );
    });

    test('returns null for a valid password', () {
      expect(AuthValidators.password('secret123'), isNull);
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
