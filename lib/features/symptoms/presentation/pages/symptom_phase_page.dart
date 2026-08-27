import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_phase_trends.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/bar_row.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/range_selector.dart';

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
          child: const _PhaseView(),
        );
      },
    );
  }
}

class _PhaseView extends StatelessWidget {
  const _PhaseView();

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
            SymptomPhaseError(:final failure) =>
              Center(child: Text(failure.message)),
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
    final visible =
        trends.phases.where((summary) => summary.count > 0).toList();
    return Column(
      children: [
        if (state.recomputing) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              RangeSelector(
                range: state.range,
                onChanged: (range) =>
                    context.read<SymptomPhaseCubit>().setRange(range),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (visible.isEmpty)
                const _EmptyPhases()
              else
                for (final summary in visible)
                  _PhaseCard(
                    summary: summary,
                    maxCount: trends.maxPhaseCount,
                  ),
            ],
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
              cyclePhaseLabel(summary.phase),
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
  const _EmptyPhases();

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
          Text('No symptoms in this window', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Log symptoms and periods to see phase patterns.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
