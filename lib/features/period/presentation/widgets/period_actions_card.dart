import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';

class PeriodActionsCard extends StatelessWidget {
  const PeriodActionsCard({super.key});

  Future<void> _pickStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now,
      helpText: 'When did your period start?',
    );
    if (picked != null && context.mounted) {
      context.read<PeriodCubit>().startPeriod(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PeriodCubit, PeriodState, CycleStats?>(
      selector: (state) => state is PeriodLoaded ? state.stats : null,
      builder: (context, stats) {
        if (stats == null) {
          return const SizedBox.shrink();
        }

        final ongoing = stats.currentPeriod;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed:
                      ongoing == null ? () => _pickStartDate(context) : null,
                  icon: const Icon(Icons.water_drop),
                  label: const Text('My period started today'),
                ),
                if (ongoing != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<PeriodCubit>().endPeriod(DateTime.now()),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('End period today'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
