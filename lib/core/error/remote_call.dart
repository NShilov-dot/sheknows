import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/core/error/error_logger.dart';
import 'package:sheknows/core/error/exceptions.dart' as app_exceptions;

/// Wraps a Supabase table call, normalising its errors onto [ServerException].
///
/// The catch-all also swallows `Model.fromJson` decode errors, so the original
/// is logged here — past this point only [fallbackMessage] survives.
Future<T> supabaseCall<T>(
  Future<T> Function() run,
  String fallbackMessage,
) async {
  try {
    return await run();
  } on PostgrestException catch (error) {
    throw app_exceptions.ServerException(error.message);
  } catch (error, stackTrace) {
    logError(error, stackTrace, context: fallbackMessage);
    throw app_exceptions.ServerException(fallbackMessage);
  }
}

/// [supabaseCall] for `supabase.auth` calls, which raise Supabase's own
/// [AuthException] rather than a [PostgrestException].
Future<T> supabaseAuthCall<T>(
  Future<T> Function() run,
  String fallbackMessage,
) async {
  try {
    return await run();
  } on AuthException catch (error) {
    throw app_exceptions.AuthException(error.message);
  } catch (error, stackTrace) {
    logError(error, stackTrace, context: fallbackMessage);
    throw app_exceptions.AuthException(fallbackMessage);
  }
}
