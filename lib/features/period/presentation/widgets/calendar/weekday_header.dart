import 'package:flutter/material.dart';

/// Monday-first row of weekday initials above the calendar grid.
class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // narrowWeekdays is Sunday-indexed; the grid is Monday-first.
    final nw = MaterialLocalizations.of(context).narrowWeekdays;
    final labels = [...nw.sublist(1), nw.first];
    return Row(
      children: [
        for (final name in labels)
          Expanded(
            child: Center(
              child: Text(
                name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
