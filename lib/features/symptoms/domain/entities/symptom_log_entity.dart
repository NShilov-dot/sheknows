import 'package:equatable/equatable.dart';

/// Fixed catalogue of symptoms a user can log. Grouped into [SymptomCategory]
/// for display via [categoryOf]. Persisted by `.name`, so don't rename values
/// without a data migration.
enum SymptomType {
  // Pain
  cramps,
  headache,
  backache,
  chestPain,
  // Mood
  irritability,
  sadness,
  anxiety,
  moodSwings,
  // Physical
  fatigue,
  energy,
  insomnia,
  // Discharge
  wateryDischarge,
  mucusDischarge,
  spottingDischarge,
  // Other
  acne,
  bloating,
  nausea,
  lowLibido,
  highLibido,
}

/// Display grouping for [SymptomType]. Not stored — derived via [categoryOf].
enum SymptomCategory { pain, mood, physical, discharge, other }

/// How strong the symptom was. `none` lets a user record that a symptom was
/// absent, not just unlogged. Persisted by `.name`.
enum SymptomSeverity { none, mild, moderate, severe }

SymptomCategory categoryOf(SymptomType type) {
  switch (type) {
    case SymptomType.cramps:
    case SymptomType.headache:
    case SymptomType.backache:
    case SymptomType.chestPain:
      return SymptomCategory.pain;
    case SymptomType.irritability:
    case SymptomType.sadness:
    case SymptomType.anxiety:
    case SymptomType.moodSwings:
      return SymptomCategory.mood;
    case SymptomType.fatigue:
    case SymptomType.energy:
    case SymptomType.insomnia:
      return SymptomCategory.physical;
    case SymptomType.wateryDischarge:
    case SymptomType.mucusDischarge:
    case SymptomType.spottingDischarge:
      return SymptomCategory.discharge;
    case SymptomType.acne:
    case SymptomType.bloating:
    case SymptomType.nausea:
    case SymptomType.lowLibido:
    case SymptomType.highLibido:
      return SymptomCategory.other;
  }
}

SymptomType? symptomTypeFromName(String? name) =>
    _byName(SymptomType.values, name);

SymptomSeverity? symptomSeverityFromName(String? name) =>
    _byName(SymptomSeverity.values, name);

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

/// A single logged symptom at a precise point in time. Multiple entries per
/// day are expected (unlike the one-row-per-day day log).
class SymptomLogEntity extends Equatable {
  const SymptomLogEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.severity,
    required this.loggedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final SymptomType type;
  final SymptomSeverity severity;

  /// Precise moment the symptom was recorded for (local time).
  final DateTime loggedAt;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, userId, type, severity, loggedAt, notes, createdAt, updatedAt];
}
