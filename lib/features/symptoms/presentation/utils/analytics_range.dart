/// Time window for the symptom analytics screens (trends, phase attribution).
enum AnalyticsRange { days30, days90, all }

extension AnalyticsRangeX on AnalyticsRange {
  String get label => switch (this) {
        AnalyticsRange.days30 => '30 days',
        AnalyticsRange.days90 => '90 days',
        AnalyticsRange.all => 'All time',
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
