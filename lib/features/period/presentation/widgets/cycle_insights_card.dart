import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';

class CycleInsightsCard extends StatelessWidget {
  const CycleInsightsCard({super.key});

  static String _formatDate(DateTime date) =>
      '${date.day} ${_statsMonthNames[date.month - 1]} ${date.year}';

  static const _statsMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static List<(String, String)> _itemsFor(CycleStats stats) => <(String, String)>[
        ('Logged periods', '${stats.periodCount}'),
        if (stats.averageCycleLength != null)
          ('Avg cycle length', '${stats.averageCycleLength} days'),
        if (stats.averagePeriodLength != null)
          ('Avg period length', '${stats.averagePeriodLength} days'),
        if (stats.currentPeriod != null)
          (
            'Current period',
            'Day ${stats.currentPeriod!.durationInDays} of bleeding',
          ),
        if (stats.hasPrediction)
          ('Next period expected', _formatDate(stats.nextPredictedStart!)),
      ];

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PeriodCubit, PeriodState, CycleStats?>(
      selector: (state) => state is PeriodLoaded ? state.stats : null,
      builder: (context, stats) {
        if (stats == null) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Insights', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                for (final item in _itemsFor(stats))
                  InsightRow(label: item.$1, value: item.$2),
                if (!stats.hasPrediction && stats.periodCount < 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Log at least two periods to see cycle predictions.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InsightRow extends StatelessWidget {
  const InsightRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
