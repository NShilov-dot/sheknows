import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';

/// A labelled horizontal bar: label, a proportional fill over a track, and the
/// value. Uses [FractionallySizedBox] — no chart dependency for a simple ranked
/// bar. Shared by the trends and phase-attribution screens.
class BarRow extends StatelessWidget {
  const BarRow({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  final String label;
  final int value;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Expanded, not Flexible: this is a ranked chart, so every bar has
          // to start at the same x. Flexible is loose, letting a short label
          // shrink-wrap and pull its bar left, which breaks the alignment the
          // old fixed 110dp box guaranteed.
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.swatch),
              child: Container(
                height: 18,
                color: theme.colorScheme.surfaceContainerHighest,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fraction.clamp(0.0, 1.0),
                  child: Container(color: color, height: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 28),
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
