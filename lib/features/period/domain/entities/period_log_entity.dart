import 'package:equatable/equatable.dart';

enum FlowLevel { light, medium, heavy }

FlowLevel? flowLevelFromName(String? name) {
  for (final level in FlowLevel.values) {
    if (level.name == name) {
      return level;
    }
  }
  return null;
}

class PeriodLogEntity extends Equatable {
  const PeriodLogEntity({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.flow,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;

  /// First day of bleeding (date only, local calendar day).
  final DateTime startDate;

  /// Last day of bleeding. Null while the period is ongoing.
  final DateTime? endDate;

  final FlowLevel? flow;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOngoing => endDate == null;

  /// Number of days from start to end, inclusive. Ongoing periods count
  /// up to today.
  int get durationInDays {
    final last = endDate ?? DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(last.year, last.month, last.day);
    return end.difference(start).inDays + 1;
  }

  /// Whether [day] falls within this period (start..end inclusive).
  bool coversDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    if (d.isBefore(start)) {
      return false;
    }
    final end = endDate == null
        ? d
        : DateTime(endDate!.year, endDate!.month, endDate!.day);
    return !d.isAfter(end);
  }

  @override
  List<Object?> get props =>
      [id, userId, startDate, endDate, flow, notes, createdAt, updatedAt];
}
