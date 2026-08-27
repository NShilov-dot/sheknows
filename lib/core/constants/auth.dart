/// Minimum length for a new password, in characters.
///
/// Lives here rather than on `AuthValidators` because the error copy that
/// quotes it is resolved in `core/error/failure_messages.dart` — keeping the
/// constant in the auth feature would make `core` depend on a feature.
/// Keep in sync with any password policy configured in Supabase Auth.
const int kMinPasswordLength = 8;
