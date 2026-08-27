import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';

/// Human-readable labels for the symptom enums. Kept in one place so the log
/// sheet and the history list stay in sync.

String cyclePhaseLabel(CyclePhase phase) => switch (phase) {
      CyclePhase.menstrual => 'Menstrual',
      CyclePhase.follicular => 'Follicular',
      CyclePhase.ovulation => 'Ovulation',
      CyclePhase.luteal => 'Luteal',
      CyclePhase.unknown => 'Unknown',
    };

String symptomTypeLabel(SymptomType type) => switch (type) {
      SymptomType.cramps => 'Cramps',
      SymptomType.headache => 'Headache',
      SymptomType.backache => 'Backache',
      SymptomType.chestPain => 'Chest pain',
      SymptomType.irritability => 'Irritability',
      SymptomType.sadness => 'Sadness',
      SymptomType.anxiety => 'Anxiety',
      SymptomType.moodSwings => 'Mood swings',
      SymptomType.fatigue => 'Fatigue',
      SymptomType.energy => 'Energy',
      SymptomType.insomnia => 'Insomnia',
      SymptomType.wateryDischarge => 'Watery',
      SymptomType.mucusDischarge => 'Mucus',
      SymptomType.spottingDischarge => 'Spotting',
      SymptomType.acne => 'Acne',
      SymptomType.bloating => 'Bloating',
      SymptomType.nausea => 'Nausea',
      SymptomType.lowLibido => 'Low libido',
      SymptomType.highLibido => 'High libido',
    };

String symptomCategoryLabel(SymptomCategory category) => switch (category) {
      SymptomCategory.pain => 'Pain',
      SymptomCategory.mood => 'Mood',
      SymptomCategory.physical => 'Physical',
      SymptomCategory.discharge => 'Discharge',
      SymptomCategory.other => 'Other',
    };

String symptomSeverityLabel(SymptomSeverity severity) => switch (severity) {
      SymptomSeverity.none => 'None',
      SymptomSeverity.mild => 'Mild',
      SymptomSeverity.moderate => 'Moderate',
      SymptomSeverity.severe => 'Severe',
    };
