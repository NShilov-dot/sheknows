import 'package:sheknows/core/constants/auth.dart';
import 'package:sheknows/core/error/validation_error.dart';

// Re-exported so call sites that already import this file for the
// validators also see the codes they return.
export 'package:sheknows/core/error/validation_error.dart';

/// Why a credential field was rejected.
///

class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _hasLetter = RegExp(r'[A-Za-z]');
  static final RegExp _hasDigit = RegExp(r'\d');

  /// Minimum length enforced for new accounts.
  /// Align this with Supabase Dashboard -> Authentication -> Providers -> Email
  /// (Password requirements) so client and server rules stay in sync.
  /// Kept as a forwarding alias so existing call sites keep reading the
  /// rule from the validator that enforces it.
  static const int minPasswordLength = kMinPasswordLength;

  static AuthValidationError? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return AuthValidationError.emailRequired;
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return AuthValidationError.emailInvalid;
    }
    return null;
  }

  /// Validates a password.
  ///
  /// Sign-in only requires a non-empty value so existing accounts are not
  /// blocked by newer strength rules. Registration enforces length, no
  /// surrounding whitespace, and at least one letter and one digit.
  static AuthValidationError? password(
    String? value, {
    bool forRegistration = false,
  }) {
    final password = value ?? '';
    if (password.isEmpty) {
      return AuthValidationError.passwordRequired;
    }

    if (!forRegistration) {
      return null;
    }

    if (password.trim() != password) {
      return AuthValidationError.passwordWhitespace;
    }
    if (password.length < minPasswordLength) {
      return AuthValidationError.passwordTooShort;
    }
    if (!_hasLetter.hasMatch(password) || !_hasDigit.hasMatch(password)) {
      return AuthValidationError.passwordWeak;
    }
    return null;
  }

  static AuthValidationError? confirmPassword(String? value, String password) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) {
      return AuthValidationError.confirmRequired;
    }
    if (confirmation != password) {
      return AuthValidationError.confirmMismatch;
    }
    return null;
  }
}
