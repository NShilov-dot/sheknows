import 'package:sheknows/l10n/app_localizations.dart';

/// Time window for the symptom analytics screens (trends, phase attribution).
enum AnalyticsRange { days30, days90, all }

extension AnalyticsRangeX on AnalyticsRange {
  String label(AppLocalizations l10n) => switch (this) {
        AnalyticsRange.days30 => l10n.commonDaysCount(30),
        AnalyticsRange.days90 => l10n.commonDaysCount(90),
        AnalyticsRange.all => l10n.symptomRangeAllTime,
      };

  Duration? get duration => switch (this) {
        AnalyticsRange.days30 => const Duration(days: 30),
        AnalyticsRange.days90 => const Duration(days: 90),
        AnalyticsRange.all => null,
      };

  /// The window's lower bound relative to [now], or null for "all time".
  DateTime? fromDate(DateTime now) {
    final window = duration;
    return window == null ? null : now.subtract(window);
  }
}
