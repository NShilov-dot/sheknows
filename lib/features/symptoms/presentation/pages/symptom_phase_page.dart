import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_phase_trends.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/bar_row.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/range_selector.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptoms_error_view.dart';

class SymptomPhasePage extends StatelessWidget {
  const SymptomPhasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, String?>(
      selector: (state) => state is AuthAuthenticated ? state.user.id : null,
      builder: (context, userId) {
        if (userId == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return BlocProvider(
          create: (_) => sl<SymptomPhaseCubit>()..load(userId),
          // The id the error state's retry re-runs the load with.
          child: _PhaseView(userId: userId),
        );
      },
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
        title: const Text('By cycle phase'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/symptoms'),
        ),
      ),
      body: BlocBuilder<SymptomPhaseCubit, SymptomPhaseState>(
        builder: (context, state) {
          return switch (state) {
            SymptomPhaseInitial() || SymptomPhaseLoading() =>
              const Center(child: CircularProgressIndicator()),
            SymptomPhaseError(:final failure) => SymptomsErrorView(
                failure: failure,
                onRetry: () => context.read<SymptomPhaseCubit>().load(userId),
              ),
            SymptomPhaseLoaded() => _Loaded(state: state),
          };
        },
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state});

  final SymptomPhaseLoaded state;

  @override
  Widget build(BuildContext context) {
    final trends = state.trends;
    final logged =
        trends.phases.where((summary) => summary.count > 0).toList();
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
        if (state.recomputing) const LinearProgressIndicator(),
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              summary.phase == CyclePhase.unknown
                  ? 'Not enough cycle data'
                  : cyclePhaseLabel(summary.phase),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            BarRow(
              label: 'Entries',
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
                        '${symptomTypeLabel(entry.type)} ×${entry.count}',
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
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline,
              size: AppIconSize.empty, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasUnplaced
                ? 'No cycle data for this window'
                : 'No symptoms in this window',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasUnplaced
                ? 'Log your period dates to see phase patterns.'
                : 'Log symptoms and periods to see phase patterns.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
