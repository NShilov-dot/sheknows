/// Application environment configuration.
///
/// Values are supplied at build/run time via `--dart-define-from-file=env.json`.
/// Copy `env.example.json` to `env.json` and fill in your Supabase credentials.
class Environment {
  /// Dev mode: boot without Supabase or auth, using in-memory sample data.
  /// Enable with `--dart-define=DEV_MODE=true`. Lets you work on the app's
  /// features and visuals before auth is wired back up.
  static const bool devMode = bool.fromEnvironment('DEV_MODE');

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Deep link used for OAuth redirect on mobile/desktop.
  /// Must match the scheme registered in the native platform config and the
  /// redirect URL added in Supabase Dashboard -> Authentication -> URL Configuration.
  ///
  /// Custom schemes are fine for local/template use. Prefer HTTPS App Links /
  /// Universal Links before shipping a production app (see README).
  static const String oauthRedirectUrl =
      'com.gaussdev.sheknows://login-callback';

  /// Throws a [StateError] if required configuration is missing.
  /// Call this during startup so misconfiguration fails fast with a clear message.
  static void validate() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw StateError(
        'Missing Supabase configuration. Provide SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY via --dart-define-from-file=env.json. '
        'See env.example.json for the expected format.',
      );
    }
  }
}
