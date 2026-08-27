import 'package:sheknows/core/constants/auth.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/error/validation_error.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Turns a [Failure] into something safe to show a user.
///
/// The data layer forwards raw backend text: `PostgrestException.message` and
/// Supabase's own `AuthException.message` travel unchanged into
/// [ServerFailure] and [AuthFailure]. Rendering `failure.message` directly —
/// which every screen used to do — leaks strings like
/// `new row violates row-level security policy for table "period_logs"` and
/// `JWT expired` into a snack bar.
///
/// So nothing is passed through: [ValidationFailure] carries an
/// [AuthValidationError.name], which is resolved back to localized copy, and
/// every other failure maps to fixed copy. The original text is kept only for
/// logging.
///
/// This is deliberately the single place user-facing error copy is decided.
String failureMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      // Authored by AuthValidators / AuthBloc: a code, not user copy.
      ValidationFailure() => _validationMessage(l10n, failure.message),
      // Flow-neutral on purpose: AuthPageScaffold is shared by login and
      // register, so naming the sign-in flow here would greet a failed
      // sign-up with the wrong verb.
      AuthFailure() => l10n.errorAuthGeneric,
      NetworkFailure() => l10n.errorNetworkOffline,
      ServerFailure() => l10n.errorServer,
      _ => l10n.errorUnknown,
    };

String _validationMessage(AppLocalizations l10n, String code) {
  for (final error in AuthValidationError.values) {
    if (error.name == code) {
      return authValidationMessage(l10n, error);
    }
  }
  // Not one of ours — never render it.
  return l10n.errorUnknown;
}

/// The untouched backend text, for logs and bug reports — never for the UI.
String failureDebugMessage(Failure failure) => failure.message;

/// Localized copy for one input-validation code.
///
/// Lives beside [failureMessage] because a [ValidationFailure] transports a
/// code and both the form fields and the failure mapper have to resolve it
/// to the same sentence.
String authValidationMessage(AppLocalizations l10n, AuthValidationError error) =>
    switch (error) {
      AuthValidationError.emailRequired => l10n.authValidationEmailRequired,
      AuthValidationError.emailInvalid => l10n.authValidationEmailInvalid,
      AuthValidationError.passwordRequired =>
        l10n.authValidationPasswordRequired,
      AuthValidationError.passwordWhitespace =>
        l10n.authValidationPasswordNoSurroundingSpaces,
      AuthValidationError.passwordTooShort =>
        l10n.authValidationPasswordTooShort(kMinPasswordLength),
      AuthValidationError.passwordWeak =>
        l10n.authValidationPasswordNeedsLetterAndNumber,
      AuthValidationError.confirmRequired =>
        l10n.authValidationConfirmPasswordRequired,
      AuthValidationError.confirmMismatch =>
        l10n.authValidationPasswordsDoNotMatch,
    };
