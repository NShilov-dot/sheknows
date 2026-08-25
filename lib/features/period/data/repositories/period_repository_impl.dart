import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/exceptions.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/period/data/datasources/period_remote_datasource.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/domain/repositories/period_repository.dart';

class PeriodRepositoryImpl implements PeriodRepository {
  PeriodRepositoryImpl(this._remoteDataSource);

  final PeriodRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<PeriodLogEntity>>> getPeriodLogs(
    String userId,
  ) async {
    try {
      final logs = await _remoteDataSource.getPeriodLogs(userId);
      return Right(logs);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PeriodLogEntity>> logPeriodStart({
    required String userId,
    required DateTime startDate,
    FlowLevel? flow,
    String? notes,
  }) async {
    try {
      final log = await _remoteDataSource.logPeriodStart(
        userId: userId,
        startDate: startDate,
        flow: flow,
        notes: notes,
      );
      return Right(log);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PeriodLogEntity>> updatePeriodLog({
    required String periodId,
    DateTime? startDate,
    DateTime? endDate,
    FlowLevel? flow,
    String? notes,
  }) async {
    try {
      final log = await _remoteDataSource.updatePeriodLog(
        periodId: periodId,
        startDate: startDate,
        endDate: endDate,
        flow: flow,
        notes: notes,
      );
      return Right(log);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePeriodLog(String periodId) async {
    try {
      await _remoteDataSource.deletePeriodLog(periodId);
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<DayLogEntity>>> getDayLogs(String userId) async {
    try {
      final logs = await _remoteDataSource.getDayLogs(userId);
      return Right(logs);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, DayLogEntity>> upsertDayLog({
    required String userId,
    required DateTime date,
    SexualActivity? sexualActivity,
    Set<Symptom> symptoms = const {},
    Mood? mood,
    String? notes,
  }) async {
    try {
      final log = await _remoteDataSource.upsertDayLog(
        userId: userId,
        date: date,
        sexualActivity: sexualActivity,
        symptoms: symptoms,
        mood: mood,
        notes: notes,
      );
      return Right(log);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteDayLog(String dayLogId) async {
    try {
      await _remoteDataSource.deleteDayLog(dayLogId);
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
