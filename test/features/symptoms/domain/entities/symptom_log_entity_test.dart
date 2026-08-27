import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';

void main() {
  group('SymptomLogEntity', () {
    test('categoryOf covers every symptom type', () {
      // No StateError / missing case for any value.
      for (final type in SymptomType.values) {
        expect(categoryOf(type), isA<SymptomCategory>());
      }
    });

    test('categoryOf groups a representative of each category', () {
      expect(categoryOf(SymptomType.cramps), SymptomCategory.pain);
      expect(categoryOf(SymptomType.anxiety), SymptomCategory.mood);
      expect(categoryOf(SymptomType.insomnia), SymptomCategory.physical);
      expect(categoryOf(SymptomType.spottingDischarge),
          SymptomCategory.discharge);
      expect(categoryOf(SymptomType.highLibido), SymptomCategory.other);
    });

    test('enum fromName helpers round-trip and reject unknown values', () {
      for (final value in SymptomType.values) {
        expect(symptomTypeFromName(value.name), value);
      }
      for (final value in SymptomSeverity.values) {
        expect(symptomSeverityFromName(value.name), value);
      }
      expect(symptomTypeFromName(null), isNull);
      expect(symptomTypeFromName('nope'), isNull);
      expect(symptomSeverityFromName('nope'), isNull);
    });

    test('equality is value based', () {
      SymptomLogEntity build() => SymptomLogEntity(
            id: 's-1',
            userId: 'user-1',
            type: SymptomType.cramps,
            severity: SymptomSeverity.moderate,
            loggedAt: DateTime(2026, 8, 20, 9),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          );
      expect(build(), equals(build()));
    });
  });
}
