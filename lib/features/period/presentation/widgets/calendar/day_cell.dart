import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/month_page.dart';

/// A single day square of the calendar grid.
class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.band,
    required this.marks,
    required this.isPredictedStart,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final BandInfo? band;
  final DayMarks marks;
  final bool isPredictedStart;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Compute "future" against a fresh clock each build so shading stays correct
    // if the app is left open across midnight (isToday uses DateTime.now() too).
    final isFuture = day.isAfter(DateTime.now());
    final hasBand = band != null;
    final isOnBand = hasBand && !isFuture;

    var labelColor = isFuture
        ? scheme.onSurface.withValues(alpha: AppAlpha.wash)
        : scheme.onSurface;
    if (isOnBand) {
      labelColor = scheme.onSecondary;
    } else if (isPredictedStart) {
      labelColor = scheme.secondary;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Continuous band behind logged period days.
          if (hasBand)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(
                      alpha: isFuture ? AppAlpha.future : AppAlpha.solid,
                    ),
                    borderRadius: BorderRadius.horizontal(
                      left: band!.extendsLeft
                          ? Radius.zero
                          : const Radius.circular(AppRadius.band),
                      right: band!.extendsRight
                          ? Radius.zero
                          : const Radius.circular(AppRadius.band),
                    ),
                  ),
                ),
              ),
            ),

          // Predicted next period start.
          if (!hasBand && isPredictedStart)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.secondary.withValues(alpha: AppAlpha.faint),
                  ),
                ),
              ),
            ),

          // Today ring.
          if (isToday)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOnBand ? scheme.onSecondary : scheme.outline,
                  width: 1.5,
                ),
              ),
            ),

          Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: labelColor,
              fontWeight: isToday || isPredictedStart
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),

          // Tracking dots (intimacy / other) under the day number.
          if (marks.hasAny)
            Positioned(
              bottom: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (marks.intimacy)
                    Dot(color: isOnBand ? scheme.onSecondary : scheme.primary),
                  if (marks.intimacy && marks.other) const SizedBox(width: 3),
                  if (marks.other)
                    Dot(color: isOnBand ? scheme.onSecondary : scheme.tertiary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Small tracking marker rendered under a day number and in the legend.
class Dot extends StatelessWidget {
  const Dot({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
