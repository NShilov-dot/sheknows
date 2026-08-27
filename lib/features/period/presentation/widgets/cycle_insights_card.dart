import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Insights', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                for (final item in _itemsFor(stats))
                  InsightRow(label: item.$1, value: item.$2),
                if (!stats.hasPrediction && stats.periodCount < 2)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          // A 3:2 split of Expanded, not spaceBetween with bare Texts: the
          // pair is ~225dp of the 256dp available at 320dp in English, so it
          // overflowed at text scale 1.3 and at 1.0 in ru/uz.
          //
          // Both children must be Expanded (tight), not Flexible (loose).
          // Flexible lets a child shrink below its share, and since Flexible
          // still claims flex: 1 the value would be allotted half the row and
          // then render at the left edge of that half — floating in the middle
          // instead of sitting flush right the way spaceBetween had it.
          Expanded(flex: 3, child: Text(label)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
