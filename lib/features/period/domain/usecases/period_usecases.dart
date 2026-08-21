import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/usecases/usecase.dart';
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
