import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/day_cell.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Key to the calendar's bands, circles and dots.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.xs,
      children: [
        _LegendItem(
          marker: Container(
            width: 18,
            height: 10,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: AppAlpha.solid),
              borderRadius: BorderRadius.horizontal(
                left: const Radius.circular(AppRadius.band),
                right: Radius.zero,
              ),
            ),
          ),
          label: l10n.cycleLegendLogged,
        ),
        _LegendItem(
          marker: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.secondary.withValues(alpha: AppAlpha.faint),
            ),
          ),
          label: l10n.cycleLegendPredicted,
        ),
        _LegendItem(
          marker: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Matches the today ring in DayCell.
              border: Border.all(color: scheme.primary, width: 1.5),
            ),
          ),
          label: l10n.cycleLegendToday,
        ),
        _LegendItem(
          marker: Dot(color: scheme.primary),
          label: l10n.cycleIntimacy,
        ),
        _LegendItem(
          marker: Dot(color: scheme.tertiary),
          label: l10n.commonNotes,
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
