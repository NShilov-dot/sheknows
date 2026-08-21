import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/presentation/widgets/moon_cycle_indicator.dart';

CycleStats _stats({int? cycleDay, int? averageCycleLength}) {
  return CycleStats(
    periodCount: averageCycleLength == null ? 0 : 2,
    averageCycleLength: averageCycleLength,
    currentCycleDay: cycleDay,
    nextPredictedStart:
        cycleDay == null ? null : DateTime(2026, 9, 1),
  );
}

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('renders day counter when a period is logged', (tester) async {
    await tester.pumpWidget(
      _wrap(MoonCycleIndicator(stats: _stats(cycleDay: 14, averageCycleLength: 28))),
    );

    expect(find.textContaining('Day 14', findRichText: true), findsOneWidget);
    expect(find.textContaining('of 28', findRichText: true), findsOneWidget);
  });

  testWidgets('hides day counter without logged periods', (tester) async {
    await tester.pumpWidget(_wrap(MoonCycleIndicator(stats: _stats())));

    expect(find.textContaining('Day', findRichText: true), findsNothing);
  });

  // Exercises the moon-path geometry at representative phases so any
  // malformed arc throws in tests rather than on device.
  for (final day in const [1, 5, 8, 14, 15, 21, 27, 28]) {
    testWidgets('paints without errors on cycle day $day', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MoonCycleIndicator(
            size: 80,
            stats: _stats(cycleDay: day, averageCycleLength: 28),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
