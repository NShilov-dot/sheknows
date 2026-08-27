import 'package:equatable/equatable.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';

/// A symptom type and how many times it was logged in the analysed window.
class SymptomTypeCount extends Equatable {
  const SymptomTypeCount(this.type, this.count);

  final SymptomType type;
  final int count;

  @override
  List<Object?> get props => [type, count];
}

/// Aggregated view of a user's symptom history over a time window.
class SymptomTrends extends Equatable {
  const SymptomTrends({
    required this.totalEntries,
    required this.byType,
    required this.bySeverity,
  });

  final int totalEntries;

  /// Per-type counts, most frequent first, only types that actually occurred.
  final List<SymptomTypeCount> byType;

  /// Count per severity; every [SymptomSeverity] is present (0 allowed).
  final Map<SymptomSeverity, int> bySeverity;

  bool get isEmpty => totalEntries == 0;

  /// The highest single-type count, used to scale bars (>= 1 to avoid /0).
  int get maxTypeCount =>
      byType.isEmpty ? 1 : byType.first.count;

  @override
  List<Object?> get props => [totalEntries, byType, bySeverity];
}

class SymptomTrendsCalculator {
  const SymptomTrendsCalculator();

  /// Aggregates [logs] (any order). When [from] is given, only entries at or
  /// after it are counted.
  SymptomTrends calculate(List<SymptomLogEntity> logs, {DateTime? from}) {
    final scoped = from == null
        ? logs
        : logs.where((log) => !log.loggedAt.isBefore(from)).toList();

    final typeCounts = <SymptomType, int>{};
    final severityCounts = <SymptomSeverity, int>{
      for (final severity in SymptomSeverity.values) severity: 0,
    };
    for (final log in scoped) {
      typeCounts.update(log.type, (value) => value + 1, ifAbsent: () => 1);
      severityCounts.update(log.severity, (value) => value + 1);
    }

    final byType = typeCounts.entries
        .map((entry) => SymptomTypeCount(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.count != a.count
          ? b.count.compareTo(a.count)
          : a.type.index.compareTo(b.type.index));

    return SymptomTrends(
      totalEntries: scoped.length,
      byType: byType,
      bySeverity: severityCounts,
    );
  }
}
