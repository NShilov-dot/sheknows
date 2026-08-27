import 'dart:developer' as developer;

/// The single place a swallowed error is recorded.
///
/// Every `catch` in the data layer routes here before its `Failure` is
/// returned, so a failure the UI renders as "Something went wrong" still leaves
/// the real exception and stack somewhere findable. Attaching a crash reporter
/// later means changing this function and nothing else.
void logError(Object error, StackTrace stackTrace, {String? context}) {
  developer.log(
    context ?? 'Unhandled failure',
    name: 'sheknows',
    error: error,
    stackTrace: stackTrace,
  );
}
