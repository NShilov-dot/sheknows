import 'package:sheknows/features/daily_log/domain/entities/daily_log_entity.dart';

class DailyLogModel extends DailyLogEntity {
  const DailyLogModel({
    required super.id,
    required super.userId,
    required super.date,
    super.mood,
    super.symptoms,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['log_date'] as String),
      mood: moodFromName(json['mood'] as String?),
      symptoms: (json['symptoms'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toUpsertJson() {
    final local = date.toLocal();
    return {
      'user_id': userId,
      'log_date':
          '${local.year.toString().padLeft(4, '0')}-'
          '${local.month.toString().padLeft(2, '0')}-'
          '${local.day.toString().padLeft(2, '0')}',
      'mood': mood?.name,
      'symptoms': symptoms,
      'notes': (notes == null || notes!.trim().isEmpty) ? null : notes!.trim(),
    };
  }
}
