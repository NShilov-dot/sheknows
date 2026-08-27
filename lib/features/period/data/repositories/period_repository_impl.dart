import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/error/guard.dart';
import 'package:sheknows/features/period/data/datasources/period_remote_datasource.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/domain/repositories/period_repository.dart';

class PeriodRepositoryImpl implements PeriodRepository {
  PeriodRepositoryImpl(this._remoteDataSource);

  final PeriodRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<PeriodLogEntity>>> getPeriodLogs(String userId) =>
      guard(() => _remoteDataSource.getPeriodLogs(userId));

  @override
  Future<Either<Failure, PeriodLogEntity>> logPeriodStart({
    required String userId,
    required DateTime startDate,
    FlowLevel? flow,
    String? notes,
  }) =>
      guard(
        () => _remoteDataSource.logPeriodStart(
          userId: userId,
          startDate: startDate,
          flow: flow,
          notes: notes,
        ),
      );

  @override
  Future<Either<Failure, PeriodLogEntity>> updatePeriodLog({
    required String periodId,
    DateTime? startDate,
    DateTime? endDate,
    FlowLevel? flow,
    String? notes,
  }) =>
      guard(
        () => _remoteDataSource.updatePeriodLog(
          periodId: periodId,
          startDate: startDate,
          endDate: endDate,
          flow: flow,
          notes: notes,
        ),
      );

  @override
  Future<Either<Failure, void>> deletePeriodLog(String periodId) =>
      guard(() => _remoteDataSource.deletePeriodLog(periodId));

  @override
  Future<Either<Failure, List<DayLogEntity>>> getDayLogs(String userId) =>
      guard(() => _remoteDataSource.getDayLogs(userId));

  @override
  Future<Either<Failure, DayLogEntity>> upsertDayLog({
    required String userId,
    required DateTime date,
    SexualActivity? sexualActivity,
    String? notes,
  }) =>
      guard(
        () => _remoteDataSource.upsertDayLog(
          userId: userId,
          date: date,
          sexualActivity: sexualActivity,
          notes: notes,
        ),
      );

  @override
  Future<Either<Failure, void>> deleteDayLog(String dayLogId) =>
      guard(() => _remoteDataSource.deleteDayLog(dayLogId));
}
