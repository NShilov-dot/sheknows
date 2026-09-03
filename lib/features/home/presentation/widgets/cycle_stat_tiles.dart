import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/utils/date_only.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Stand-in for a figure the data cannot give yet (no prediction, symptoms
/// still loading). A typographic mark, so deliberately not localized.
const _noValue = '—';

/// Four figures at a glance: when the next period is due, the average cycle
/// and period lengths, and how many symptoms were logged in the last
/// [symptomsWindowDays] days.
class CycleStatTiles extends StatelessWidget {
  const CycleStatTiles({
    super.key,
    required this.stats,
    required this.symptomCount,
    required this.symptomsWindowDays,
  });

  final CycleStats stats;

  /// Null while the symptom logs are loading or after they failed to load.
  final int? symptomCount;
  final int symptomsWindowDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final next = stats.nextPredictedStart;
    // The calculator rolls a passed prediction forward, so this is >= 1.
    final daysUntilNext =
        next?.dateOnly.difference(DateTime.now().dateOnly).inDays;
    final avgCycle = stats.averageCycleLength;
    final avgPeriod = stats.averagePeriodLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TileRow(
          left: StatTile(
            caption: l10n.cycleInsightsNextPeriod,
            value: daysUntilNext == null
                ? _noValue
                : l10n.commonDaysCount(daysUntilNext),
            detail: next == null ? null : l10n.cycleNextPeriodDate(next),
          ),
          right: StatTile(
            caption: l10n.cycleInsightsAvgCycleLength,
            value: avgCycle == null ? _noValue : l10n.commonDaysCount(avgCycle),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _TileRow(
          left: StatTile(
            caption: l10n.cycleInsightsAvgPeriodLength,
            value:
                avgPeriod == null ? _noValue : l10n.commonDaysCount(avgPeriod),
          ),
          right: StatTile(
            caption: l10n.symptomsTitle,
            value: symptomCount == null
                ? _noValue
                : NumberFormat.decimalPattern(l10n.localeName)
                    .format(symptomCount),
            detail: l10n.homeLastDays(symptomsWindowDays),
          ),
        ),
        // Same condition as CycleInsightsCard: one period gives a cycle day
        // but no averages, so three of the four tiles sit empty.
        if (!stats.hasPrediction && stats.periodCount < 2)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              l10n.cycleInsightsPredictionHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Two tiles side by side, stretched to the taller one so a two-line caption
/// on one does not leave the other short.
class _TileRow extends StatelessWidget {
  const _TileRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: right),
        ],
      ),
    );
  }
}

/// One dashboard figure: a small caption, the value, and an optional detail
/// line under it.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.caption,
    required this.value,
    this.detail,
  });

  final String caption;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caption,
              style: theme.textTheme.labelMedium?.copyWith(color: muted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Values are short ("12 days", "7"); the scale-down is a guard for
            // the uz/ru renderings in a 106dp tile at 320dp, not the norm. A
            // truncated figure would be worse than a slightly smaller one.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: theme.textTheme.titleLarge),
            ),
            if (detail != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                detail!,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
