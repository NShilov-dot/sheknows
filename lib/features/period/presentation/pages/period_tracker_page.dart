import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/widgets/load_error_view.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_gate.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/period/presentation/widgets/cycle_calendar_card.dart';
import 'package:sheknows/features/period/presentation/widgets/cycle_insights_card.dart';
import 'package:sheknows/features/period/presentation/widgets/cycle_moon_header.dart';
import 'package:sheknows/features/period/presentation/widgets/period_actions_card.dart';
import 'package:sheknows/features/period/presentation/widgets/period_history_list.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The Cycle tab. Its [PeriodCubit] comes from `AppShell`, shared with the
/// dashboard, so the two never disagree about what has been logged.
class PeriodTrackerPage extends StatelessWidget {
  const PeriodTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The id is what the error state's retry re-runs the load with.
    return AuthGate(
      builder: (context, userId) => _PeriodTrackerView(userId: userId),
    );
  }
}

class _PeriodTrackerView extends StatelessWidget {
  const _PeriodTrackerView({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).cycleTitle),
      ),
      // Mutation failures are announced by AppShell, which owns the cubit.
      body: BlocBuilder<PeriodCubit, PeriodState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (state) {
              PeriodInitial() || PeriodLoading() => const _PeriodSkeleton(
                  key: ValueKey('loading'),
                ),
              PeriodError(:final failure) => LoadErrorView(
                  key: const ValueKey('error'),
                  failure: failure,
                  onRetry: () => context.read<PeriodCubit>().load(userId),
                ),
              PeriodLoaded() => const _PeriodBody(key: ValueKey('loaded')),
            },
          );
        },
      ),
    );
  }
}

class _PeriodBody extends StatelessWidget {
  const _PeriodBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            const CycleMoonHeader(),
            const CycleCalendarCard(),
            const SizedBox(height: AppSpacing.lg),
            const CycleInsightsCard(),
            const SizedBox(height: AppSpacing.lg),
            const PeriodActionsCard(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppLocalizations.of(context).cycleHistoryTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const PeriodHistoryList(),
          ],
        ),
      ),
    );
  }
}

/// The loading arm. The page structure is known before the data is, so a
/// placeholder of roughly the loaded shape beats a centred spinner and the
/// layout does not jump when the data lands.
class _PeriodSkeleton extends StatelessWidget {
  const _PeriodSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SkeletonBlock(height: 320, color: fill),
            const SizedBox(height: AppSpacing.lg),
            _SkeletonBlock(height: 160, color: fill),
            const SizedBox(height: AppSpacing.lg),
            _SkeletonBlock(height: 120, color: fill),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    );
  }
}
