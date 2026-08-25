import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';

DayLogEntity _log({
  SexualActivity? sexualActivity,
  Set<Symptom> symptoms = const {},
  Mood? mood,
  String? notes,
}) {
  return DayLogEntity(
    id: 'day-1',
    userId: 'user-1',
    date: DateTime(2026, 8, 20),
    sexualActivity: sexualActivity,
    symptoms: symptoms,
    mood: mood,
    notes: notes,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('DayLogEntity', () {
    test('is empty when nothing is tracked', () {
      expect(_log().isEmpty, isTrue);
      expect(_log(notes: '   ').isEmpty, isTrue, reason: 'blank notes are empty');
      expect(_log().hasData, isFalse);
    });

    test('has data when any tracker is set', () {
      expect(_log(sexualActivity: SexualActivity.protected).hasData, isTrue);
      expect(_log(symptoms: {Symptom.cramps}).hasData, isTrue);
      expect(_log(mood: Mood.happy).hasData, isTrue);
      expect(_log(notes: 'note').hasData, isTrue);
    });

    test('isOnDay ignores the time component', () {
      final log = _log();
      expect(log.isOnDay(DateTime(2026, 8, 20, 23, 59)), isTrue);
      expect(log.isOnDay(DateTime(2026, 8, 21)), isFalse);
    });

    test('enum fromName helpers round-trip and reject unknown values', () {
      for (final value in SexualActivity.values) {
        expect(sexualActivityFromName(value.name), value);
      }
      for (final value in Symptom.values) {
        expect(symptomFromName(value.name), value);
      }
      for (final value in Mood.values) {
        expect(moodFromName(value.name), value);
      }
      expect(sexualActivityFromName(null), isNull);
      expect(symptomFromName('nope'), isNull);
      expect(moodFromName('nope'), isNull);
    });

    test('equality treats symptoms as an unordered set', () {
      final a = _log(symptoms: {Symptom.cramps, Symptom.acne});
      final b = _log(symptoms: {Symptom.acne, Symptom.cramps});
      expect(a, equals(b));
    });
  });
}
