import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/usecases/usecase.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/domain/repositories/period_repository.dart';

class GetPeriodLogsParams {
  const GetPeriodLogsParams({required this.userId});

  final String userId;
}

class GetPeriodLogsUseCase
    implements UseCase<List<PeriodLogEntity>, GetPeriodLogsParams> {
  GetPeriodLogsUseCase(this._repository);

  final PeriodRepository _repository;

  @override
  Future<Either<Failure, List<PeriodLogEntity>>> call(
    GetPeriodLogsParams params,
  ) {
    return _repository.getPeriodLogs(params.userId);
  }
}

class LogPeriodStartParams {
  const LogPeriodStartParams({
    required this.userId,
    required this.startDate,
    this.flow,
    this.notes,
  });

  final String userId;
  final DateTime startDate;
  final FlowLevel? flow;
  final String? notes;
}

class LogPeriodStartUseCase
    implements UseCase<PeriodLogEntity, LogPeriodStartParams> {
  LogPeriodStartUseCase(this._repository);

  final PeriodRepository _repository;

  @override
  Future<Either<Failure, PeriodLogEntity>> call(LogPeriodStartParams params) {
    return _repository.logPeriodStart(
      userId: params.userId,
      startDate: params.startDate,
      flow: params.flow,
      notes: params.notes,
    );
  }
}

class UpdatePeriodLogParams {
  const UpdatePeriodLogParams({
    required this.periodId,
    this.startDate,
    this.endDate,
    this.flow,
    this.notes,
  });

  final String periodId;
  final DateTime? startDate;
  final DateTime? endDate;
  final FlowLevel? flow;
  final String? notes;
}

class UpdatePeriodLogUseCase
    implements UseCase<PeriodLogEntity, UpdatePeriodLogParams> {
  UpdatePeriodLogUseCase(this._repository);

  final PeriodRepository _repository;

  @override
  Future<Either<Failure, PeriodLogEntity>> call(UpdatePeriodLogParams params) {
    return _repository.updatePeriodLog(
      periodId: params.periodId,
      startDate: params.startDate,
      endDate: params.endDate,
      flow: params.flow,
      notes: params.notes,
    );
  }
}

class DeletePeriodLogParams {
  const DeletePeriodLogParams(this.periodId);

  final String periodId;
}

class DeletePeriodLogUseCase implements UseCase<void, DeletePeriodLogParams> {
  DeletePeriodLogUseCase(this._repository);

  final PeriodRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeletePeriodLogParams params) {
    return _repository.deletePeriodLog(params.periodId);
  }
}

// -- Day logs (intimacy / symptoms / mood / notes) ---------------------------

class GetDayLogsParams {
  const GetDayLogsParams({required this.userId});

  final String userId;
}

class GetDayLogsUseCase implements UseCase<List<DayLogEntity>, GetDayLogsParams> {
  GetDayLogsUseCase(this._repository);

  final PeriodRepository _repository;

  @override
  Future<Either<Failure, List<DayLogEntity>>> call(GetDayLogsParams params) {
    return _repository.getDayLogs(params.userId);
  }
}

class UpsertDayLogParams {
  const UpsertDayLogParams({
    required this.userId,
    required this.date,
    this.sexualActivity,
    this.notes,
  });

  final String userId;
  final DateTime date;
  final SexualActivity? sexualActivity;
  final String? notes;
}

class UpsertDayLogUseCase implements UseCase<DayLogEntity, UpsertDayLogParams> {
  UpsertDayLogUseCase(this._repository);

  final PeriodRepository _repository;

  @override
  Future<Either<Failure, DayLogEntity>> call(UpsertDayLogParams params) {
    return _repository.upsertDayLog(
      userId: params.userId,
      date: params.date,
      sexualActivity: params.sexualActivity,
      notes: params.notes,
    );
  }
}

class DeleteDayLogParams {
  const DeleteDayLogParams(this.dayLogId);

  final String dayLogId;
}

class DeleteDayLogUseCase implements UseCase<void, DeleteDayLogParams> {
  DeleteDayLogUseCase(this._repository);

  final PeriodRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteDayLogParams params) {
    return _repository.deleteDayLog(params.dayLogId);
  }
}
