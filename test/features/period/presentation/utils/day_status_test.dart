import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sheknows/l10n/app_localizations.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/utils/day_status.dart';

PeriodLogEntity _log({
  required DateTime start,
  DateTime? end,
  String id = 'log-1',
}) {
  return PeriodLogEntity(
    id: id,
    userId: 'user-1',
    startDate: start,
    endDate: end,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  // The status lines are ARB keys now, so the expectations read the same keys
  // through the English bundle rather than re-hardcoding English here.
  late AppLocalizations l10n;
  setUpAll(() async {
    initializeDateFormatting();
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  final today = DateTime(2026, 8, 21);
  final logs = [
    _log(start: DateTime(2026, 7, 1), end: DateTime(2026, 7, 5), id: 'a'),
    _log(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 5), id: 'b'),
  ];
  final stats = const CycleStatsCalculator().calculate(logs, now: today);

  String labelFor(DateTime day) => dayStatusLabel(
        l10n: l10n,
        day: day,
        today: today,
        logs: logs,
        stats: stats,
      );

  test('labels a day inside a finished period', () {
    expect(labelFor(DateTime(2026, 8, 2)), l10n.cycleStatusDayOfPeriod(5, 2));
  });

  test('labels a day inside an ongoing period', () {
    final ongoing = [_log(start: DateTime(2026, 8, 19), id: 'c')];
    expect(
      dayStatusLabel(
        l10n: l10n,
        day: DateTime(2026, 8, 20),
        today: today,
        logs: ongoing,
        stats: const CycleStatsCalculator().calculate(ongoing, now: today),
      ),
      l10n.cycleStatusBleedingDay(2),
    );
  });

  test('labels the predicted start', () {
    expect(labelFor(stats.nextPredictedStart!), l10n.cycleStatusPredictedStart);
  });

  test('labels the current cycle day', () {
    expect(labelFor(DateTime(2026, 8, 10)), l10n.cycleStatusCycleDay(10));
  });

  test('labels a future day with no data', () {
    expect(labelFor(DateTime(2026, 12, 25)), l10n.cycleStatusUpcoming);
  });

  test('labels a past day with no data', () {
    expect(labelFor(DateTime(2026, 1, 1)), l10n.cycleStatusNoData);
  });
}
