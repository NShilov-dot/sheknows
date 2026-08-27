import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/month_page.dart';
import 'package:sheknows/l10n/app_localizations.dart';

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

    final Color labelColor;
    if (isOnBand) {
      labelColor = scheme.onSecondary;
    } else if (isPredictedStart) {
      labelColor = scheme.secondary;
    } else if (isFuture) {
      // A washed label over a future band composites down to 2.3:1, so days
      // on a band keep an opaque colour (7.6:1); elsewhere `muted` is 5.8:1.
      labelColor = hasBand
          ? scheme.onSurface
          : scheme.onSurface.withValues(alpha: AppAlpha.muted);
    } else {
      labelColor = scheme.onSurface;
    }

    return Semantics(
      button: true,
      container: true,
      selected: isOnBand,
      label: _semanticsLabel(
        AppLocalizations.of(context),
        hasBand: hasBand,
        isFuture: isFuture,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // A ripple is invisible under the period band, so the selection click
        // is the only feedback this tap gives before the sheet animates in.
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
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
              FractionallySizedBox(
                widthFactor: 0.78,
                heightFactor: 0.78,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // `outline` is 2.2:1 on the card — below the 3:1 floor for
                    // a meaningful non-text mark. `primary` is 9.1:1 on the
                    // card and 5.0:1 over a future band, and it is the app's
                    // interactive accent, which is what "today" is.
                    border: Border.all(
                      color: isOnBand ? scheme.onSecondary : scheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

            // The number is already part of the cell's composed label.
            ExcludeSemantics(
              child: Text(
                '${day.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: labelColor,
                  fontWeight: isToday || isPredictedStart
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
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
                      Dot(
                          color:
                              isOnBand ? scheme.onSecondary : scheme.primary),
                    if (marks.intimacy && marks.other) const SizedBox(width: 3),
                    if (marks.other)
                      Dot(
                          color:
                              isOnBand ? scheme.onSecondary : scheme.tertiary),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The screen-reader label: the date followed by whichever states the cell
  /// paints.
  String _semanticsLabel(
    AppLocalizations l10n, {
    required bool hasBand,
    required bool isFuture,
  }) {
    final states = <String>[
      if (hasBand)
        isFuture
            ? l10n.cycleDayCellStatePredictedPeriod
            : l10n.cycleDayCellStatePeriodLogged,
      if (isPredictedStart) l10n.cycleDayCellStatePredictedStart,
      if (isToday) l10n.cycleDayCellStateToday,
      if (marks.intimacy) l10n.cycleDayCellStateIntimacyLogged,
      if (marks.other) l10n.cycleDayCellStateHasNotes,
    ];
    // The joined form would leave a dangling separator with no states.
    return states.isEmpty
        ? l10n.cycleDayCellSemanticsDateOnly(day)
        : l10n.cycleDayCellSemantics(day, states.join(', '));
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
