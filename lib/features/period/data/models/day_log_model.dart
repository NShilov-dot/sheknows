import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';

class DayLogModel extends DayLogEntity {
  const DayLogModel({
    required super.id,
    required super.userId,
    required super.date,
    super.sexualActivity,
    super.symptoms,
    super.mood,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DayLogModel.fromJson(Map<String, dynamic> json) {
    return DayLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['log_date'] as String),
      sexualActivity:
          sexualActivityFromName(json['sexual_activity'] as String?),
      symptoms: _symptomsFrom(json['symptoms']),
      mood: moodFromName(json['mood'] as String?),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Row shape for `upsert` on the `(user_id, log_date)` unique key. Cleared
  /// fields are written as explicit nulls so an update wipes them.
  Map<String, dynamic> toUpsertJson() {
    return {
      'user_id': userId,
      'log_date': _dateString(date),
      'sexual_activity': sexualActivity?.name,
      'symptoms': symptoms.map((s) => s.name).toList(),
      'mood': mood?.name,
      'notes': (notes == null || notes!.trim().isEmpty) ? null : notes!.trim(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static Set<Symptom> _symptomsFrom(dynamic raw) {
    if (raw is! List) {
      return const {};
    }
    final result = <Symptom>{};
    for (final item in raw) {
      final symptom = symptomFromName(item as String?);
      if (symptom != null) {
        result.add(symptom);
      }
    }
    return result;
  }

  static String _dateString(DateTime date) {
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
