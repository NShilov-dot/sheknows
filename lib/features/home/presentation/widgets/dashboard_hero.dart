import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/widgets/moon_cycle_indicator.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The dashboard's opening card: the cycle moon beside today's cycle day and
/// phase. Before the first period is logged it is the prompt to log one.
class DashboardHero extends StatelessWidget {
  const DashboardHero({super.key, required this.stats, required this.logs});

  final CycleStats stats;
  final List<PeriodLogEntity> logs;

  static const _moonSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final day = stats.currentCycleDay;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GlowingMoon(
                  phase: MoonCycleIndicator.phaseOf(stats),
                  size: _moonSize,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: day == null
                      ? Text(
                          l10n.cycleHistoryEmptyTitle,
                          style: theme.textTheme.titleMedium,
                        )
                      : _CycleToday(day: day, stats: stats, logs: logs),
                ),
              ],
            ),
            // Below the row, full width: beside a 64dp moon the button does
            // not fit its Russian label at 320dp.
            if (day == null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => context.go('/cycle'),
                icon: const Icon(Icons.calendar_month),
                label: Text(l10n.homeTrackCycleButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CycleToday extends StatelessWidget {
  const _CycleToday({
    required this.day,
    required this.stats,
    required this.logs,
  });

  final int day;
  final CycleStats stats;
  final List<PeriodLogEntity> logs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final phase = const CyclePhaseCalculator().phaseOn(
      DateTime.now(),
      periods: logs,
      averageCycleLength: stats.averageCycleLength,
      averagePeriodLength: stats.averagePeriodLength,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.cycleMoonDayOfTotal(
              day, MoonCycleIndicator.cycleLengthOf(stats)),
          style: theme.textTheme.headlineSmall,
        ),
        // `unknown` is "not enough history to place today", not a phase; the
        // prediction hint under the tiles explains what to log.
        if (phase != CyclePhase.unknown) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            cyclePhaseLabel(l10n, phase),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
