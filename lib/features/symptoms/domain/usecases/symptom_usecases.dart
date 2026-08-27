import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/usecases/usecase.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/repositories/symptom_repository.dart';

class GetSymptomLogsParams {
  const GetSymptomLogsParams({required this.userId, this.from, this.to});

  final String userId;
  final DateTime? from;
  final DateTime? to;
}

class GetSymptomLogsUseCase
    implements UseCase<List<SymptomLogEntity>, GetSymptomLogsParams> {
  GetSymptomLogsUseCase(this._repository);

  final SymptomRepository _repository;

  @override
  Future<Either<Failure, List<SymptomLogEntity>>> call(
    GetSymptomLogsParams params,
  ) {
    return _repository.getSymptomLogs(
      params.userId,
      from: params.from,
      to: params.to,
    );
  }
}

class LogSymptomParams {
  const LogSymptomParams({
    required this.userId,
    required this.type,
    required this.severity,
    required this.loggedAt,
    this.notes,
  });

  final String userId;
  final SymptomType type;
  final SymptomSeverity severity;
  final DateTime loggedAt;
  final String? notes;
}

class LogSymptomUseCase implements UseCase<SymptomLogEntity, LogSymptomParams> {
  LogSymptomUseCase(this._repository);

  final SymptomRepository _repository;

  @override
  Future<Either<Failure, SymptomLogEntity>> call(LogSymptomParams params) {
    return _repository.logSymptom(
      userId: params.userId,
      type: params.type,
      severity: params.severity,
      loggedAt: params.loggedAt,
      notes: params.notes,
    );
  }
}

class UpdateSymptomLogParams {
  const UpdateSymptomLogParams({
    required this.id,
    this.type,
    this.severity,
    this.loggedAt,
    this.notes,
  });

  final String id;
  final SymptomType? type;
  final SymptomSeverity? severity;
  final DateTime? loggedAt;
  final String? notes;
}

class UpdateSymptomLogUseCase
    implements UseCase<SymptomLogEntity, UpdateSymptomLogParams> {
  UpdateSymptomLogUseCase(this._repository);

  final SymptomRepository _repository;

  @override
  Future<Either<Failure, SymptomLogEntity>> call(UpdateSymptomLogParams params) {
    return _repository.updateSymptomLog(
      id: params.id,
      type: params.type,
      severity: params.severity,
      loggedAt: params.loggedAt,
      notes: params.notes,
    );
  }
}

class DeleteSymptomLogParams {
  const DeleteSymptomLogParams(this.id);

  final String id;
}

class DeleteSymptomLogUseCase
    implements UseCase<void, DeleteSymptomLogParams> {
  DeleteSymptomLogUseCase(this._repository);

  final SymptomRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteSymptomLogParams params) {
    return _repository.deleteSymptomLog(params.id);
  }
}
