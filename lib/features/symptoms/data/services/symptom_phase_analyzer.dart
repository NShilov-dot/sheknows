import 'package:flutter/foundation.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_phase_trends.dart';

/// Runs the (pure) phase attribution off the UI isolate via [compute]. One
/// short-lived isolate per call — recalcs are user-driven (open screen, change
/// window), so spawn+copy overhead is imperceptible and there's no isolate
/// lifecycle to manage. A concrete class so cubit tests can mock it and skip
/// spawning a real isolate.
class SymptomPhaseAnalyzer {
  const SymptomPhaseAnalyzer();

  Future<SymptomPhaseTrends> analyze(SymptomPhaseInput input) =>
      compute(computeSymptomPhaseTrends, input);
}
