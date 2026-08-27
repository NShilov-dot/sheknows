import 'package:flutter/material.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_trends.dart';
import 'package:sheknows/features/symptoms/presentation/utils/analytics_range.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/bar_row.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/range_selector.dart';

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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RangeSelector(
          range: _range,
          onChanged: (range) => setState(() {
            _range = range;
            _trends = _calculate();
          }),
        ),
        const SizedBox(height: 16),
        if (trends.isEmpty)
          const _EmptyTrends()
        else ...[
          _SummaryCard(total: trends.totalEntries),
          const SizedBox(height: 24),
          _FrequencySection(trends: trends),
          const SizedBox(height: 24),
          _SeveritySection(trends: trends),
        ],
      ],
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.insights, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              '$total ${total == 1 ? 'entry' : 'entries'} logged',
              style: theme.textTheme.titleMedium,
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
        Text('Most frequent', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        for (final entry in trends.byType)
          BarRow(
            label: symptomTypeLabel(entry.type),
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
        Text('By severity', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        for (final severity in SymptomSeverity.values)
          BarRow(
            label: symptomSeverityLabel(severity),
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
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          Icon(Icons.insights_outlined,
              size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('No symptoms in this window', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Log symptoms to see your trends.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
