import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/day_cell.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/month_page.dart';
import 'package:sheknows/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      // The cell composes its semantics label through AppLocalizations.
      // Pinned to English so the label below is deterministic.
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: Center(child: SizedBox.square(dimension: 48, child: child))),
    );

DayCell _cell({
  required DateTime day,
  BandInfo? band,
  DayMarks marks = const DayMarks(intimacy: false, other: false),
  bool isPredictedStart = false,
  bool isToday = false,
}) =>
    DayCell(
      day: day,
      band: band,
      marks: marks,
      isPredictedStart: isPredictedStart,
      isToday: isToday,
      onTap: () {},
    );

void main() {
  setUpAll(initializeDateFormatting);

  late AppLocalizations en;
  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
  });

  testWidgets('announces the date and every painted state once',
      (tester) async {
    final handle = tester.ensureSemantics();
    final today = DateTime.now();

    await tester.pumpWidget(
      _wrap(
        _cell(
          day: DateTime(today.year, today.month, today.day),
          band: const BandInfo(extendsLeft: false, extendsRight: false),
          marks: const DayMarks(intimacy: true, other: true),
          isToday: true,
        ),
      ),
    );

    // Both the date order and the separators come from the ARB keys, so the
    // expectation cannot drift from what the widget builds.
    final expected = en.cycleDayCellSemantics(
      DateTime(today.year, today.month, today.day),
      [
        en.cycleDayCellStatePeriodLogged,
        en.cycleDayCellStateToday,
        en.cycleDayCellStateIntimacyLogged,
        en.cycleDayCellStateHasNotes,
      ].join(', '),
    );

    expect(
      tester.getSemantics(find.byType(DayCell)),
      matchesSemantics(
        isButton: true,
        isSelected: true,
        hasTapAction: true,
        hasSelectedState: true,
        label: expected,
      ),
    );
    handle.dispose();
  });

  testWidgets('a future band reads as predicted, not logged', (tester) async {
    final handle = tester.ensureSemantics();
    final future = DateTime.now().add(const Duration(days: 40));

    await tester.pumpWidget(
      _wrap(
        _cell(
          day: DateTime(future.year, future.month, future.day),
          band: const BandInfo(extendsLeft: false, extendsRight: false),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(DayCell)).label,
      endsWith(', ${en.cycleDayCellStatePredictedPeriod}'),
    );
    handle.dispose();
  });
}
