import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_phase_trends.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/bar_row.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/range_selector.dart';
import 'package:sheknows/core/widgets/load_error_view.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_gate.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class SymptomPhasePage extends StatelessWidget {
  const SymptomPhasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      builder: (context, userId) => BlocProvider(
        create: (_) => sl<SymptomPhaseCubit>()..load(userId),
        // The id the error state's retry re-runs the load with.
        child: _PhaseView(userId: userId),
      ),
    );
  }
}

class _PhaseView extends StatelessWidget {
  const _PhaseView({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).symptomPhaseTitle),
        leading: BackButton(onPressed: () => context.go('/symptoms')),
      ),
      body: BlocBuilder<SymptomPhaseCubit, SymptomPhaseState>(
        builder: (context, state) {
          // Keyed branches so the spinner cross-fades into the phase cards.
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (state) {
              SymptomPhaseInitial() || SymptomPhaseLoading() => const Center(
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(),
                ),
              SymptomPhaseError(:final failure) => LoadErrorView(
                  key: const ValueKey('error'),
                  failure: failure,
                  onRetry: () => context.read<SymptomPhaseCubit>().load(userId),
                ),
              SymptomPhaseLoaded() =>
                _Loaded(key: const ValueKey('loaded'), state: state),
            },
          );
        },
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({super.key, required this.state});

  final SymptomPhaseLoaded state;

  @override
  Widget build(BuildContext context) {
    final trends = state.trends;
    final logged = trends.phases.where((summary) => summary.count > 0).toList();
    // CyclePhase.unknown is the calculator's "could not place this day" bucket,
    // not a phase. On its own it means the user has symptoms but no period
    // dates to attribute them to, which is guidance, not a chart.
    final placed = [
      for (final summary in logged)
        if (summary.phase != CyclePhase.unknown) summary,
    ];
    final unplaced = [
      for (final summary in logged)
        if (summary.phase == CyclePhase.unknown) summary,
    ];
    final visible = [...placed, ...unplaced];
    return Column(
      children: [
        // Always occupied: inserting/removing the bar shoved the list 4dp on
        // every range change.
        SizedBox(
          height: 4,
          child: state.recomputing
              ? const LinearProgressIndicator(minHeight: 4)
              : null,
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg + MediaQuery.viewPaddingOf(context).bottom,
                ),
                children: [
                  RangeSelector(
                    range: state.range,
                    onChanged: (range) =>
                        context.read<SymptomPhaseCubit>().setRange(range),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (placed.isEmpty)
                    _EmptyPhases(hasUnplaced: unplaced.isNotEmpty)
                  else
                    for (final summary in visible)
                      _PhaseCard(
                        summary: summary,
                        maxCount: trends.maxPhaseCount,
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.summary, required this.maxCount});

  final PhaseSummary summary;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              summary.phase == CyclePhase.unknown
                  ? l10n.symptomPhaseNotEnoughCycleData
                  : cyclePhaseLabel(l10n, summary.phase),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            BarRow(
              label: l10n.symptomPhaseEntriesBarLabel,
              value: summary.count,
              fraction: summary.count / maxCount,
              color: theme.colorScheme.primary,
            ),
            if (summary.topTypes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final entry in summary.topTypes)
                    Chip(
                      label: Text(
                        l10n.symptomPhaseTypeCountChip(
                          symptomTypeLabel(l10n, entry.type),
                          entry.count,
                        ),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyPhases extends StatelessWidget {
  const _EmptyPhases({required this.hasUnplaced});

  /// True when symptoms were logged in this window but no period dates place
  /// them in a phase — the fix is logging periods, not logging more symptoms.
  final bool hasUnplaced;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline,
              size: AppIconSize.empty,
              color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasUnplaced
                ? l10n.symptomPhaseNoCycleDataTitle
                : l10n.symptomEmptyWindowTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasUnplaced
                ? l10n.symptomPhaseEmptyLogPeriodsBody
                : l10n.symptomPhaseEmptyLogBothBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
