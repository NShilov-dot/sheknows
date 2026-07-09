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
  static const int minPasswordLength = 8;

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates a password.
  ///
  /// Sign-in only requires a non-empty value so existing accounts are not
  /// blocked by newer strength rules. Registration enforces length, no
  /// surrounding whitespace, and at least one letter and one digit.
  static String? password(String? value, {bool forRegistration = false}) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (!forRegistration) {
      return null;
    }

    if (password.trim() != password) {
      return 'Password cannot start or end with spaces';
    }
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    if (!_hasLetter.hasMatch(password) || !_hasDigit.hasMatch(password)) {
      return 'Password must include at least one letter and one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) {
      return 'Confirm your password';
    }
    if (confirmation != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
