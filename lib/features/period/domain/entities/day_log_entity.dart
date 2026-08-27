import 'package:equatable/equatable.dart';

/// Intimacy logged for a day, including whether protection was used.
/// A day with no intimacy simply has no value (and often no [DayLogEntity]).
enum SexualActivity { protected, unprotected }

SexualActivity? sexualActivityFromName(String? name) =>
    _byName(SexualActivity.values, name);

T? _byName<T extends Enum>(List<T> values, String? name) {
  if (name == null) {
    return null;
  }
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}

/// A day's self-tracked data that is separate from the period itself:
/// intimacy and a free-text note. One row per user per day. Symptoms are
/// tracked by the dedicated `symptoms` feature, not here.
class DayLogEntity extends Equatable {
  const DayLogEntity({
    required this.id,
    required this.userId,
    required this.date,
    this.sexualActivity,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;

  /// Calendar day this log applies to (date only, local calendar day).
  final DateTime date;

  final SexualActivity? sexualActivity;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True when nothing is tracked. An empty log should be deleted rather than
  /// stored, so the calendar never shows a marker for a blank day.
  bool get isEmpty =>
      sexualActivity == null && (notes == null || notes!.trim().isEmpty);

  bool get hasData => !isEmpty;

  bool isOnDay(DateTime day) =>
      date.year == day.year && date.month == day.month && date.day == day.day;

  @override
  List<Object?> get props =>
      [id, userId, date, sexualActivity, notes, createdAt, updatedAt];
}
