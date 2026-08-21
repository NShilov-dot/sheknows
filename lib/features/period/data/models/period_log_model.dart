import 'package:supabase_flutter_starter_kit/features/period/domain/entities/period_log_entity.dart';

class PeriodLogModel extends PeriodLogEntity {
  const PeriodLogModel({
    required super.id,
    required super.userId,
    required super.startDate,
    super.endDate,
    super.flow,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PeriodLogModel.fromJson(Map<String, dynamic> json) {
    return PeriodLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      flow: flowLevelFromName(json['flow'] as String?),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'start_date': _dateString(startDate),
      if (endDate != null) 'end_date': _dateString(endDate!),
      if (flow != null) 'flow': flow!.name,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }

  static String _dateString(DateTime date) {
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
