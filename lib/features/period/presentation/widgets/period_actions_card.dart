import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class PeriodActionsCard extends StatelessWidget {
  const PeriodActionsCard({super.key});

  Future<void> _pickStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now,
      helpText: AppLocalizations.of(context).cyclePeriodStartPickerHelp,
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
        final l10n = AppLocalizations.of(context);
        final (stats, isLoading) = selected;
        if (stats == null) {
          return const SizedBox.shrink();
        }

        final ongoing = stats.currentPeriod;
        // startPeriod emits the optimistic log AND isLoading in ONE emit, so
        // `ongoing` is already non-null while the write is still in flight —
        // keying the spinner off `ongoing == null` put it on an "End period"
        // button the user never pressed. The optimistic row is the one with a
        // `pending-` id, which is what actually distinguishes the two.
        final startInFlight =
            isLoading && (ongoing == null || ongoing.id.startsWith('pending-'));

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
                  icon: startInFlight
                      ? const _ButtonSpinner()
                      : const Icon(Icons.water_drop),
                  label: Text(l10n.cycleStartPeriodButton),
                ),
                // Held back until the start actually lands, so the two buttons
                // do not swap under the user's thumb mid-write.
                if (ongoing != null && !startInFlight) ...[
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    // No spinner branch here: endPeriod never sets isLoading,
                    // so a spinner on this button could only ever belong to an
                    // unrelated mutation. Disabling is honest; showing progress
                    // for someone else's work is not.
                    onPressed: isLoading
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            context
                                .read<PeriodCubit>()
                                .endPeriod(DateTime.now());
                          },
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text(l10n.cycleEndPeriodButton),
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
