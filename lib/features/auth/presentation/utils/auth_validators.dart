class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static const int minPasswordLength = 6;

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

  static String? password(String? value, {bool forRegistration = false}) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    if (forRegistration && password.trim() != password) {
      return 'Password cannot start or end with spaces';
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
