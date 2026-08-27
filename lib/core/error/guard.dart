import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/error_logger.dart';
import 'package:sheknows/core/error/exceptions.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/error/failure_messages.dart';

/// Runs a data-source call and converts its exceptions into [Failure]s.
///
/// Each repository used to spell this out itself, identically, and discard the
/// error — a failed write left no trace. One funnel, so [logError] sees every
/// one. [failureMessage] decides the copy, so only the subtype matters here.
Future<Either<Failure, T>> guard<T>(Future<T> Function() run) async {
  try {
    return Right<Failure, T>(await run());
  } on ServerException catch (error, stackTrace) {
    logError(error, stackTrace);
    return Left<Failure, T>(ServerFailure(error.message));
  } catch (error, stackTrace) {
    logError(error, stackTrace);
    return Left<Failure, T>(const UnknownFailure());
  }
}

/// [guard] for the auth feature, whose data source reports failures as
/// [AuthException] and — for account deletion alone — [ServerException].
Future<Either<Failure, T>> guardAuth<T>(Future<T> Function() run) async {
  try {
    return Right<Failure, T>(await run());
  } on AuthException catch (error, stackTrace) {
    logError(error, stackTrace);
    return Left<Failure, T>(AuthFailure(error.message));
  } on ServerException catch (error, stackTrace) {
    logError(error, stackTrace);
    return Left<Failure, T>(ServerFailure(error.message));
  } catch (error, stackTrace) {
    logError(error, stackTrace);
    return Left<Failure, T>(const UnknownFailure());
  }
}
