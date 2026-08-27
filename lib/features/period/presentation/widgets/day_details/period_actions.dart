import 'package:flutter/material.dart';

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
  });

  final bool canStartHere;
  final bool canEndHere;

  /// Id of the period covering this day, when it is a saved one that may be
  /// deleted. Null hides the delete button.
  final String? deletablePeriodId;

  final VoidCallback onStart;
  final VoidCallback onEnd;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final deletableId = deletablePeriodId;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canStartHere)
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.water_drop),
            label: const Text('Period started on this day'),
          ),
        if (canEndHere) ...[
          if (canStartHere) const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onEnd,
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('End period on this day'),
          ),
        ],
        if (deletableId != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => onDelete(deletableId),
            icon: Icon(Icons.delete_outline, color: scheme.error),
            label: Text(
              'Delete this period',
              style: TextStyle(color: scheme.error),
            ),
          ),
        ],
      ],
    );
  }
}
