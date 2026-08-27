import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/presentation/widgets/moon_cycle_indicator.dart';
import 'package:sheknows/l10n/app_localizations.dart';

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
      // The indicator reads every string through AppLocalizations. Pinned to
      // English so the assertions below stay deterministic.
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUpAll(initializeDateFormatting);

  // Assertions read the same keys the widget does, rather than restating the
  // English copy a second time.
  late AppLocalizations en;
  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
  });
  testWidgets('renders day counter when a period is logged', (tester) async {
    await tester.pumpWidget(
      _wrap(MoonCycleIndicator(stats: _stats(cycleDay: 14, averageCycleLength: 28))),
    );

    expect(find.text(en.cycleMoonDayOfTotal(14, 28)), findsOneWidget);
  });

  testWidgets('day counter honours the system text scaler', (tester) async {
    Future<Size> counterSize(double scale) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: _wrap(
            MoonCycleIndicator(
              stats: _stats(cycleDay: 14, averageCycleLength: 28),
            ),
          ),
        ),
      );
      return tester.getSize(find.text(en.cycleMoonDayOfTotal(14, 28)));
    }

    final small = await counterSize(1);
    final large = await counterSize(2);

    expect(large.height, greaterThan(small.height));
  });

  testWidgets('reads as a single semantics node', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(MoonCycleIndicator(stats: _stats(cycleDay: 14, averageCycleLength: 28))),
    );

    expect(
      find.bySemanticsLabel(
        en.cycleMoonSemantics(
          14,
          28,
          en.cycleMoonPhaseWaxingGibbous,
          en.cycleMoonHintWaxingGibbous,
        ),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('hides day counter without logged periods', (tester) async {
    await tester.pumpWidget(_wrap(MoonCycleIndicator(stats: _stats())));

    // The whole `if (day != null)` block is gone: counter and phase line.
    expect(find.byType(Text), findsNothing);
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
