import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Human-readable labels for the symptom enums. Kept in one place so the log
/// sheet and the history list stay in sync.

String cyclePhaseLabel(AppLocalizations l10n, CyclePhase phase) =>
    switch (phase) {
      CyclePhase.menstrual => l10n.cyclePhaseMenstrual,
      CyclePhase.follicular => l10n.cyclePhaseFollicular,
      CyclePhase.ovulation => l10n.cyclePhaseOvulation,
      CyclePhase.luteal => l10n.cyclePhaseLuteal,
      CyclePhase.unknown => l10n.cyclePhaseUnknown,
    };

String symptomTypeLabel(AppLocalizations l10n, SymptomType type) =>
    switch (type) {
      SymptomType.cramps => l10n.symptomTypeCramps,
      SymptomType.headache => l10n.symptomTypeHeadache,
      SymptomType.backache => l10n.symptomTypeBackache,
      SymptomType.chestPain => l10n.symptomTypeChestPain,
      SymptomType.irritability => l10n.symptomTypeIrritability,
      SymptomType.sadness => l10n.symptomTypeSadness,
      SymptomType.anxiety => l10n.symptomTypeAnxiety,
      SymptomType.moodSwings => l10n.symptomTypeMoodSwings,
      SymptomType.fatigue => l10n.symptomTypeFatigue,
      SymptomType.energy => l10n.symptomTypeEnergy,
      SymptomType.insomnia => l10n.symptomTypeInsomnia,
      SymptomType.wateryDischarge => l10n.symptomTypeWateryDischarge,
      SymptomType.mucusDischarge => l10n.symptomTypeMucusDischarge,
      SymptomType.spottingDischarge => l10n.symptomTypeSpottingDischarge,
      SymptomType.acne => l10n.symptomTypeAcne,
      SymptomType.bloating => l10n.symptomTypeBloating,
      SymptomType.nausea => l10n.symptomTypeNausea,
      SymptomType.lowLibido => l10n.symptomTypeLowLibido,
      SymptomType.highLibido => l10n.symptomTypeHighLibido,
    };

String symptomCategoryLabel(AppLocalizations l10n, SymptomCategory category) =>
    switch (category) {
      SymptomCategory.pain => l10n.symptomCategoryPain,
      SymptomCategory.mood => l10n.symptomCategoryMood,
      SymptomCategory.physical => l10n.symptomCategoryPhysical,
      SymptomCategory.discharge => l10n.symptomCategoryDischarge,
      SymptomCategory.other => l10n.symptomCategoryOther,
    };

String symptomSeverityLabel(AppLocalizations l10n, SymptomSeverity severity) =>
    switch (severity) {
      SymptomSeverity.none => l10n.symptomSeverityNone,
      SymptomSeverity.mild => l10n.symptomSeverityMild,
      SymptomSeverity.moderate => l10n.symptomSeverityModerate,
      SymptomSeverity.severe => l10n.symptomSeveritySevere,
    };
