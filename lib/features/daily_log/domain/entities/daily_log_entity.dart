import 'package:equatable/equatable.dart';

enum Mood { happy, calm, sad, irritable, anxious, energetic }

Mood? moodFromName(String? name) {
  for (final mood in Mood.values) {
    if (mood.name == name) {
      return mood;
    }
  }
  return null;
}

/// Fixed symptom catalog. Values are stored as plain strings in
/// `daily_logs.symptoms`; keep this list in sync with the UI chips.
const kSymptomCatalog = <String>[
  'Cramps',
  'Headache',
  'Bloating',
  'Fatigue',
  'Acne',
  'Breast tenderness',
  'Back pain',
  'Nausea',
  'Insomnia',
  'Cravings',
];

class DailyLogEntity extends Equatable {
  const DailyLogEntity({
    required this.id,
    required this.userId,
    required this.date,
    this.mood,
    this.symptoms = const <String>[],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;

  /// Calendar day this log belongs to (date only).
  final DateTime date;
  final Mood? mood;
  final List<String> symptoms;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, userId, date, mood, symptoms, notes, createdAt, updatedAt];
}
