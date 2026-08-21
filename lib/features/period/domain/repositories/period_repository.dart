import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';

abstract class PeriodRepository {
  /// All period logs for [userId], newest first.
  Future<Either<Failure, List<PeriodLogEntity>>> getPeriodLogs(String userId);

  Future<Either<Failure, PeriodLogEntity>> logPeriodStart({
    required String userId,
    required DateTime startDate,
    FlowLevel? flow,
    String? notes,
  });

  Future<Either<Failure, PeriodLogEntity>> updatePeriodLog({
    required String periodId,
    DateTime? startDate,
    DateTime? endDate,
    FlowLevel? flow,
    String? notes,
  });

  Future<Either<Failure, void>> deletePeriodLog(String periodId);
}
