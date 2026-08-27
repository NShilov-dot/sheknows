/// Stable codes for the input-validation failures the app can produce.
///
/// These live in `core/error` rather than beside the validators because
/// [ValidationFailure] carries a code across the layer boundary and
/// `failure_messages.dart` has to resolve it. Putting the enum in the auth
/// feature would make `core` depend on a feature's presentation layer.
///
/// The names are part of the contract: `ValidationFailure` transports
/// `code.name`, so renaming a value changes what a failure resolves to.
enum AuthValidationError {
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordWhitespace,
  passwordTooShort,
  passwordWeak,
  confirmRequired,
  confirmMismatch,
}
