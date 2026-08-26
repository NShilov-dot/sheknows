import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/usecases/usecase.dart';
import 'package:sheknows/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:sheknows/features/daily_log/domain/repositories/daily_log_repository.dart';

class GetDailyLogParams {
  const GetDailyLogParams({required this.userId, required this.date});

  final String userId;
  final DateTime date;
}

class GetDailyLogUseCase
    implements UseCase<DailyLogEntity?, GetDailyLogParams> {
  GetDailyLogUseCase(this._repository);

  final DailyLogRepository _repository;

  @override
  Future<Either<Failure, DailyLogEntity?>> call(GetDailyLogParams params) {
    return _repository.getLog(userId: params.userId, date: params.date);
  }
}

class SaveDailyLogUseCase implements UseCase<DailyLogEntity, DailyLogEntity> {
  SaveDailyLogUseCase(this._repository);

  final DailyLogRepository _repository;

  @override
  Future<Either<Failure, DailyLogEntity>> call(DailyLogEntity log) {
    return _repository.saveLog(log);
  }
}
