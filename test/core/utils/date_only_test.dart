import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/core/utils/date_only.dart';

void main() {
  test('dateOnly strips the time of day', () {
    expect(
      DateTime(2026, 3, 14, 22, 45, 12).dateOnly,
      DateTime(2026, 3, 14),
    );
  });

  test('endOfDay is the last instant of the same date', () {
    final end = DateTime(2026, 3, 14, 1).endOfDay;
    expect(end, DateTime(2026, 3, 14, 23, 59, 59, 999));
    expect(end.day, 14);
  });
}
