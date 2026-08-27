import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The period start / end / delete buttons that make sense for the tapped day.
///
/// Renders nothing when none of them apply.
class PeriodActions extends StatelessWidget {
  const PeriodActions({
    super.key,
    required this.canStartHere,
    required this.canEndHere,
    required this.deletablePeriodId,
    required this.onStart,
    required this.onEnd,
    required this.onDelete,
    this.busy = false,
  });

  final bool canStartHere;
  final bool canEndHere;

  /// Id of the period covering this day, when it is a saved one that may be
  /// deleted. Null hides the delete button.
  final String? deletablePeriodId;

  final VoidCallback onStart;
  final VoidCallback onEnd;
  final ValueChanged<String> onDelete;

  /// True while a period mutation is already in flight. PeriodCubit drops a
  /// second one silently, so leaving these live would buzz, close the sheet
  /// and write nothing.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final deletableId = deletablePeriodId;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canStartHere)
          FilledButton.icon(
            onPressed: busy ? null : onStart,
            icon: const Icon(Icons.water_drop),
            label: Text(l10n.cyclePeriodStartedOnThisDay),
          ),
        if (canEndHere) ...[
          if (canStartHere) const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: busy ? null : onEnd,
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text(l10n.cycleEndPeriodOnThisDay),
          ),
        ],
        if (deletableId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: busy ? null : () => onDelete(deletableId),
            icon: Icon(Icons.delete_outline, color: scheme.error),
            label: Text(
              l10n.cycleDeleteThisPeriod,
              style: TextStyle(color: scheme.error),
            ),
          ),
        ],
      ],
    );
  }
}
