import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/exceptions.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/daily_log/data/datasources/daily_log_remote_datasource.dart';
import 'package:sheknows/features/daily_log/data/models/daily_log_model.dart';
import 'package:sheknows/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:sheknows/features/daily_log/domain/repositories/daily_log_repository.dart';

class DailyLogRepositoryImpl implements DailyLogRepository {
  DailyLogRepositoryImpl(this._remoteDataSource);

  final DailyLogRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, DailyLogEntity?>> getLog({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final log = await _remoteDataSource.getDailyLog(
        userId: userId,
        date: date,
      );
      return Right(log);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, DailyLogEntity>> saveLog(
    DailyLogEntity log,
  ) async {
    try {
      final saved = await _remoteDataSource.upsertDailyLog(
        DailyLogModel(
          id: log.id,
          userId: log.userId,
          date: log.date,
          mood: log.mood,
          symptoms: log.symptoms,
          notes: log.notes,
          createdAt: log.createdAt,
          updatedAt: log.updatedAt,
        ),
      );
      return Right(saved);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
