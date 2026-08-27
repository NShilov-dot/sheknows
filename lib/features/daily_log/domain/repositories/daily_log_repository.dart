import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/daily_log/domain/entities/daily_log_entity.dart';

abstract class DailyLogRepository {
  /// The log for a specific day, or null if the day has no entry.
  Future<Either<Failure, DailyLogEntity?>> getLog({
    required String userId,
    required DateTime date,
  });

  /// Creates or updates the log for the day embedded in [log].
  Future<Either<Failure, DailyLogEntity>> saveLog(DailyLogEntity log);
}
