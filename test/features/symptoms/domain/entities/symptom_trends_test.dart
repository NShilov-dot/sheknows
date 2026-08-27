import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_trends.dart';

SymptomLogEntity _log({
  required SymptomType type,
  SymptomSeverity severity = SymptomSeverity.moderate,
  required DateTime loggedAt,
}) {
  return SymptomLogEntity(
    id: 's-${type.name}-${loggedAt.microsecondsSinceEpoch}',
    userId: 'user-1',
    type: type,
    severity: severity,
    loggedAt: loggedAt,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  const calculator = SymptomTrendsCalculator();
  final now = DateTime(2026, 8, 26, 12);

  group('SymptomTrendsCalculator', () {
    test('empty input yields an empty result with all severities present', () {
      final trends = calculator.calculate(const []);
      expect(trends.isEmpty, isTrue);
      expect(trends.totalEntries, 0);
      expect(trends.byType, isEmpty);
      expect(trends.bySeverity.keys, containsAll(SymptomSeverity.values));
      expect(trends.bySeverity.values, everyElement(0));
      expect(trends.maxTypeCount, 1); // never divides by zero
    });

    test('counts per type, most frequent first', () {
      final trends = calculator.calculate([
        _log(type: SymptomType.cramps, loggedAt: now),
        _log(type: SymptomType.cramps, loggedAt: now),
        _log(type: SymptomType.cramps, loggedAt: now),
        _log(type: SymptomType.headache, loggedAt: now),
        _log(type: SymptomType.acne, loggedAt: now),
        _log(type: SymptomType.acne, loggedAt: now),
      ]);
      expect(trends.totalEntries, 6);
      expect(trends.byType.first, const SymptomTypeCount(SymptomType.cramps, 3));
      expect(trends.byType[1], const SymptomTypeCount(SymptomType.acne, 2));
      expect(trends.byType[2], const SymptomTypeCount(SymptomType.headache, 1));
      expect(trends.maxTypeCount, 3);
    });

    test('breaks count ties by enum order', () {
      final trends = calculator.calculate([
        _log(type: SymptomType.headache, loggedAt: now),
        _log(type: SymptomType.cramps, loggedAt: now),
      ]);
      // cramps.index < headache.index, so cramps comes first on a tie.
      expect(trends.byType.map((e) => e.type),
          [SymptomType.cramps, SymptomType.headache]);
    });

    test('tallies severities', () {
      final trends = calculator.calculate([
        _log(type: SymptomType.cramps, severity: SymptomSeverity.severe, loggedAt: now),
        _log(type: SymptomType.cramps, severity: SymptomSeverity.severe, loggedAt: now),
        _log(type: SymptomType.acne, severity: SymptomSeverity.mild, loggedAt: now),
      ]);
      expect(trends.bySeverity[SymptomSeverity.severe], 2);
      expect(trends.bySeverity[SymptomSeverity.mild], 1);
      expect(trends.bySeverity[SymptomSeverity.none], 0);
    });

    test('from excludes entries before the window', () {
      final trends = calculator.calculate(
        [
          _log(type: SymptomType.cramps, loggedAt: now),
          _log(
            type: SymptomType.headache,
            loggedAt: now.subtract(const Duration(days: 40)),
          ),
        ],
        from: now.subtract(const Duration(days: 30)),
      );
      expect(trends.totalEntries, 1);
      expect(trends.byType.single.type, SymptomType.cramps);
    });
  });
}
