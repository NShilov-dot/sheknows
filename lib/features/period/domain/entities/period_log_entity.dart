import 'package:equatable/equatable.dart';
import 'package:sheknows/core/utils/date_only.dart';

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
  /// up to [now] (defaults to the current time).
  int durationInDays({DateTime? now}) {
    final last = endDate ?? now ?? DateTime.now();
    final start = startDate.dateOnly;
    final end = last.dateOnly;
    return end.difference(start).inDays + 1;
  }

  /// Whether [day] falls within this period (start..end inclusive).
  bool coversDay(DateTime day) {
    final d = day.dateOnly;
    final start = startDate.dateOnly;
    if (d.isBefore(start)) {
      return false;
    }
    final end = endDate == null
        ? d
        : endDate!.dateOnly;
    return !d.isAfter(end);
  }

  @override
  List<Object?> get props =>
      [id, userId, startDate, endDate, flow, notes, createdAt, updatedAt];
}
