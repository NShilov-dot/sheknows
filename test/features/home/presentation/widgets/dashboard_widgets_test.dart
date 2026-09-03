import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/features/home/presentation/widgets/cycle_stat_tiles.dart';
import 'package:sheknows/features/home/presentation/widgets/dashboard_hero.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The dashboard widgets derive their copy from [CycleStats] and the period
/// logs; these pin the derivations (countdown, phase, empty fallbacks) and the
/// 320dp / translated layout the rest of the app is held to.
void main() {
  setUpAll(initializeDateFormatting);

  // The narrowest phone still receiving OS updates (iPhone SE 1st gen).
  const narrow = Size(320, 568);

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = narrow;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // The 16dp page gutter the real dashboard uses.
        home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }

  // Calendar arithmetic, not Duration: a Duration across a DST change lands
  // an hour short and .dateOnly would then read one day early.
  final now = DateTime.now();
  DateTime daysFromToday(int days) =>
      DateTime(now.year, now.month, now.day + days);

  // Day 16 of a 28-day cycle: one period that started 15 days ago.
  final periodStart = daysFromToday(-15);
  final logs = [
    PeriodLogEntity(
      id: 'p1',
      userId: 'u',
      startDate: periodStart,
      endDate: daysFromToday(-11),
      createdAt: periodStart,
      updatedAt: periodStart,
    ),
  ];
  final stats = CycleStats(
    periodCount: 3,
    averageCycleLength: 28,
    averagePeriodLength: 5,
    currentCycleDay: 16,
    nextPredictedStart: daysFromToday(12),
  );

  group('CycleStatTiles', () {
    testWidgets('shows the countdown, averages and symptom count', (t) async {
      await pump(
        t,
        CycleStatTiles(stats: stats, symptomCount: 7, symptomsWindowDays: 30),
      );
      expect(t.takeException(), isNull);
      expect(find.text('12 days'), findsOneWidget);
      expect(find.text('28 days'), findsOneWidget);
      expect(find.text('5 days'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Last 30 days'), findsOneWidget);
    });

    testWidgets('dashes out what one period cannot tell, and says why',
        (t) async {
      await pump(
        t,
        const CycleStatTiles(
          stats: CycleStats(periodCount: 1, currentCycleDay: 3),
          symptomCount: null,
          symptomsWindowDays: 30,
        ),
      );
      expect(t.takeException(), isNull);
      // Next period, both averages, and the still-loading symptom count.
      expect(find.text('—'), findsNWidgets(4));
      expect(
        find.text('Log at least two periods to see cycle predictions.'),
        findsOneWidget,
      );
    });

    testWidgets('does not overflow at 320dp in Russian', (t) async {
      await pump(
        t,
        CycleStatTiles(
            stats: stats, symptomCount: 1234, symptomsWindowDays: 30),
        locale: const Locale('ru'),
      );
      expect(t.takeException(), isNull);
    });
  });

  group('DashboardHero', () {
    testWidgets('names the cycle day and the phase it falls in', (t) async {
      await pump(t, DashboardHero(stats: stats, logs: logs));
      expect(t.takeException(), isNull);
      expect(find.text('Day 16 of 28'), findsOneWidget);
      // Ovulation ≈ day 14 of 28; day 16 is past its ±1 window.
      expect(find.text('Luteal'), findsOneWidget);
    });

    testWidgets('offers to start tracking before the first period', (t) async {
      await pump(
        t,
        const DashboardHero(stats: CycleStats(periodCount: 0), logs: []),
        locale: const Locale('ru'),
      );
      expect(t.takeException(), isNull);
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });
}
