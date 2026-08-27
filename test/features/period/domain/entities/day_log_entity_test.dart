import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';

DayLogEntity _log({
  SexualActivity? sexualActivity,
  String? notes,
}) {
  return DayLogEntity(
    id: 'day-1',
    userId: 'user-1',
    date: DateTime(2026, 8, 20),
    sexualActivity: sexualActivity,
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
      expect(sexualActivityFromName(null), isNull);
      expect(sexualActivityFromName('nope'), isNull);
    });
  });
}
