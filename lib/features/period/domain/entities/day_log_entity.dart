import 'package:equatable/equatable.dart';

/// Intimacy logged for a day, including whether protection was used.
/// A day with no intimacy simply has no value (and often no [DayLogEntity]).
enum SexualActivity { protected, unprotected }

/// Physical symptoms that can be flagged for a day (multi-select).
enum Symptom {
  cramps,
  headache,
  bloating,
  tenderBreasts,
  backache,
  fatigue,
  acne,
  nausea,
  cravings,
}

/// Overall mood for a day (single choice).
enum Mood { happy, calm, energetic, sensitive, sad, anxious, irritable, tired }

SexualActivity? sexualActivityFromName(String? name) =>
    _byName(SexualActivity.values, name);

Symptom? symptomFromName(String? name) => _byName(Symptom.values, name);

Mood? moodFromName(String? name) => _byName(Mood.values, name);

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
/// intimacy, symptoms, mood, and a free-text note. One row per user per day.
class DayLogEntity extends Equatable {
  const DayLogEntity({
    required this.id,
    required this.userId,
    required this.date,
    this.sexualActivity,
    this.symptoms = const {},
    this.mood,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;

  /// Calendar day this log applies to (date only, local calendar day).
  final DateTime date;

  final SexualActivity? sexualActivity;
  final Set<Symptom> symptoms;
  final Mood? mood;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True when nothing is tracked. An empty log should be deleted rather than
  /// stored, so the calendar never shows a marker for a blank day.
  bool get isEmpty =>
      sexualActivity == null &&
      symptoms.isEmpty &&
      mood == null &&
      (notes == null || notes!.trim().isEmpty);

  bool get hasData => !isEmpty;

  bool isOnDay(DateTime day) =>
      date.year == day.year && date.month == day.month && date.day == day.day;

  @override
  List<Object?> get props =>
      [id, userId, date, sexualActivity, symptoms, mood, notes, createdAt, updatedAt];
}
