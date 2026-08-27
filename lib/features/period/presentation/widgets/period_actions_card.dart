import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      HapticFeedback.mediumImpact();
      context.read<PeriodCubit>().startPeriod(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PeriodCubit, PeriodState, (CycleStats?, bool)>(
      selector: (state) => state is PeriodLoaded
          ? (state.stats, state.isLoading)
          : (null, false),
      builder: (context, selected) {
        final (stats, isLoading) = selected;
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
                  onPressed: isLoading || ongoing != null
                      ? null
                      : () => _pickStartDate(context),
                  // Only one of the two is ever actionable, so the in-flight
                  // mutation belongs to whichever that is.
                  icon: isLoading && ongoing == null
                      ? const _ButtonSpinner()
                      : const Icon(Icons.water_drop),
                  label: const Text('My period started today'),
                ),
                if (ongoing != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            context
                                .read<PeriodCubit>()
                                .endPeriod(DateTime.now());
                          },
                    icon: isLoading
                        ? const _ButtonSpinner()
                        : const Icon(Icons.stop_circle_outlined),
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

/// A spinner sized to sit where a button's leading icon does, so swapping one
/// for the other does not resize the button.
class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: AppIconSize.md,
      height: AppIconSize.md,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
