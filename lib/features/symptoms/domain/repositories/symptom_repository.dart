import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';

abstract class SymptomRepository {
  /// Logged symptoms for [userId], newest first. Optionally bounded to the
  /// inclusive `[from, to]` window (used to show a single day's entries).
  Future<Either<Failure, List<SymptomLogEntity>>> getSymptomLogs(
    String userId, {
    DateTime? from,
    DateTime? to,
  });

  Future<Either<Failure, SymptomLogEntity>> logSymptom({
    required String userId,
    required SymptomType type,
    required SymptomSeverity severity,
    required DateTime loggedAt,
    String? notes,
  });

  Future<Either<Failure, SymptomLogEntity>> updateSymptomLog({
    required String id,
    SymptomType? type,
    SymptomSeverity? severity,
    DateTime? loggedAt,
    String? notes,
  });

  Future<Either<Failure, void>> deleteSymptomLog(String id);
}
