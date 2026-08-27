import 'package:sheknows/core/error/failures.dart';

/// Turns a [Failure] into something safe to show a user.
///
/// The data layer forwards raw backend text: `PostgrestException.message` and
/// Supabase's own `AuthException.message` travel unchanged into
/// [ServerFailure] and [AuthFailure]. Rendering `failure.message` directly —
/// which every screen used to do — leaks strings like
/// `new row violates row-level security policy for table "period_logs"` and
/// `JWT expired` into a snack bar.
///
/// So: [ValidationFailure] messages are ours and authored for people, and pass
/// through. Everything else is replaced with fixed copy and the original is
/// kept only for logging.
///
/// This is deliberately the single place user-facing error copy is decided.
/// When localization lands, this function takes an `AppLocalizations` and
/// nothing else in the app has to change.
String failureMessage(Failure failure) => switch (failure) {
      // Authored by AuthValidators / AuthBloc, already user-facing.
      ValidationFailure() => failure.message,
      AuthFailure() => _authMessage,
      NetworkFailure() => _networkMessage,
      ServerFailure() => _serverMessage,
      _ => _unknownMessage,
    };

/// The untouched backend text, for logs and bug reports — never for the UI.
String failureDebugMessage(Failure failure) => failure.message;

const _authMessage =
    'We could not sign you in. Check your details and try again.';

const _networkMessage =
    "You're offline. Your changes are saved on this device and will sync when "
    'the connection returns.';

const _serverMessage =
    'Something went wrong on our end. Please try again in a moment.';

const _unknownMessage = 'Something went wrong. Please try again.';
