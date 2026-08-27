import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/day_cell.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/month_page.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
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

    final expected = '${today.day} '
        '${const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][today.month - 1]}'
        ', period logged, today, intimacy logged, has notes';

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
      endsWith(', predicted period'),
    );
    handle.dispose();
  });
}
