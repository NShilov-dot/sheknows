import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The date line plus the one-line cycle status at the top of the day sheet.
class DayHeader extends StatelessWidget {
  const DayHeader({super.key, required this.day, required this.status});

  final DateTime day;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).cycleDayHeaderDate(day),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: AppIconSize.sm,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                status,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
