import 'package:flutter/material.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/day_cell.dart';

/// Key to the calendar's bands, circles and dots.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 4,
      children: [
        _LegendItem(
          marker: Container(
            width: 18,
            height: 10,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.horizontal(
                left: const Radius.circular(6),
                right: Radius.zero,
              ),
            ),
          ),
          label: 'Logged',
        ),
        _LegendItem(
          marker: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.secondary.withValues(alpha: 0.15),
            ),
          ),
          label: 'Predicted',
        ),
        _LegendItem(
          marker: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outline, width: 1.5),
            ),
          ),
          label: 'Today',
        ),
        _LegendItem(
          marker: Dot(color: scheme.primary),
          label: 'Intimacy',
        ),
        _LegendItem(
          marker: Dot(color: scheme.tertiary),
          label: 'Notes',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.marker, required this.label});

  final Widget marker;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        marker,
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
