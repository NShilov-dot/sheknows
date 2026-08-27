import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_trends.dart';
import 'package:sheknows/features/symptoms/presentation/utils/analytics_range.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/bar_row.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/range_selector.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Loaded body of the symptom trends screen: range selector, summary card and
/// the frequency/severity breakdowns. Owns the selected [AnalyticsRange] so a
/// range change rebuilds only this subtree.
class SymptomTrendsBody extends StatefulWidget {
  const SymptomTrendsBody({super.key, required this.logs});

  final List<SymptomLogEntity> logs;

  @override
  State<SymptomTrendsBody> createState() => _SymptomTrendsBodyState();
}

class _SymptomTrendsBodyState extends State<SymptomTrendsBody> {
  static const _calculator = SymptomTrendsCalculator();
  AnalyticsRange _range = AnalyticsRange.days30;
  late SymptomTrends _trends;

  @override
  void initState() {
    super.initState();
    _trends = _calculate();
  }

  @override
  void didUpdateWidget(SymptomTrendsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logs != widget.logs) {
      _trends = _calculate();
    }
  }

  SymptomTrends _calculate() =>
      _calculator.calculate(widget.logs, from: _range.fromDate(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    final trends = _trends;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            RangeSelector(
              range: _range,
              onChanged: (range) => setState(() {
                _range = range;
                _trends = _calculate();
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (trends.isEmpty)
              const _EmptyTrends()
            else ...[
              _SummaryCard(total: trends.totalEntries),
              const SizedBox(height: AppSpacing.xl),
              _FrequencySection(trends: trends),
              const SizedBox(height: AppSpacing.xl),
              _SeveritySection(trends: trends),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.insights, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                AppLocalizations.of(context).symptomTrendsEntriesLogged(total),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencySection extends StatelessWidget {
  const _FrequencySection({required this.trends});

  final SymptomTrends trends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).symptomTrendsMostFrequent,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final entry in trends.byType)
          BarRow(
            label: symptomTypeLabel(AppLocalizations.of(context), entry.type),
            value: entry.count,
            fraction: entry.count / trends.maxTypeCount,
            color: theme.colorScheme.primary,
          ),
      ],
    );
  }
}

class _SeveritySection extends StatelessWidget {
  const _SeveritySection({required this.trends});

  final SymptomTrends trends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount = trends.bySeverity.values
        .fold<int>(1, (max, count) => count > max ? count : max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).symptomTrendsBySeverity,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final severity in SymptomSeverity.values)
          BarRow(
            label: symptomSeverityLabel(AppLocalizations.of(context), severity),
            value: trends.bySeverity[severity] ?? 0,
            fraction: (trends.bySeverity[severity] ?? 0) / maxCount,
            color: theme.colorScheme.tertiary,
          ),
      ],
    );
  }
}

class _EmptyTrends extends StatelessWidget {
  const _EmptyTrends();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          Icon(Icons.insights_outlined,
              size: AppIconSize.empty, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.symptomEmptyWindowTitle,
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.symptomTrendsEmptyBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
