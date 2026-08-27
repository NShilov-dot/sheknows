import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';

class SymptomLogModel extends SymptomLogEntity {
  const SymptomLogModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.severity,
    required super.loggedAt,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SymptomLogModel.fromJson(Map<String, dynamic> json) {
    return SymptomLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: symptomTypeFromName(json['symptom_type'] as String?)!,
      severity: symptomSeverityFromName(json['severity'] as String?)!,
      loggedAt: DateTime.parse(json['logged_at'] as String).toLocal(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Row shape for Supabase insert/update. `id`/`created_at` are server-owned
  /// on insert; the local id is never sent.
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'symptom_type': type.name,
      'severity': severity.name,
      'logged_at': loggedAt.toUtc().toIso8601String(),
      'notes': _cleanNotes(notes),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Full serialisation for the local Hive cache/outbox (keeps id/timestamps).
  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'user_id': userId,
      'symptom_type': type.name,
      'severity': severity.name,
      'logged_at': loggedAt.toUtc().toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  static String? _cleanNotes(String? notes) {
    if (notes == null) {
      return null;
    }
    final trimmed = notes.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
