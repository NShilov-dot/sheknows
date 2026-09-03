import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/constants/home.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/widgets/load_error_view.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_gate.dart';
import 'package:sheknows/features/home/presentation/widgets/cycle_stat_tiles.dart';
import 'package:sheknows/features/home/presentation/widgets/dashboard_hero.dart';
import 'package:sheknows/features/home/presentation/widgets/top_symptoms_card.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/period/presentation/widgets/cycle_calendar_card.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_trends.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/core/widgets/skeleton_box.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The dashboard: where the cycle stands today, the numbers behind it, this
/// month's calendar, and what has been bothering the user lately.
///
/// Reads the [PeriodCubit] and [SymptomsCubit] that `AppShell` provides above
/// the tabs — the same instances the Cycle and Symptoms tabs mutate, so a
/// period logged over there is already here when the user comes back.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      builder: (context, userId) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).homeAppBarTitle),
        ),
        body: BlocBuilder<PeriodCubit, PeriodState>(
          // A mutation's isLoading flip or a mutationFailure emit changes
          // nothing here; the shell shows the snack bar.
          buildWhen: (previous, current) =>
              previous is! PeriodLoaded ||
              current is! PeriodLoaded ||
              previous.stats != current.stats ||
              previous.logs != current.logs,
          builder: (context, state) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (state) {
              PeriodInitial() ||
              PeriodLoading() =>
                const _DashboardSkeleton(key: ValueKey('loading')),
              PeriodError(:final failure) => LoadErrorView(
                  key: const ValueKey('error'),
                  failure: failure,
                  onRetry: () => context.read<PeriodCubit>().load(userId),
                ),
              PeriodLoaded(:final stats, :final logs) => _Dashboard(
                  key: const ValueKey('loaded'),
                  stats: stats,
                  logs: logs,
                  userId: userId,
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    super.key,
    required this.stats,
    required this.logs,
    required this.userId,
  });

  final CycleStats stats;
  final List<PeriodLogEntity> logs;
  final String userId;

  static const _calculator = SymptomTrendsCalculator();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SymptomsCubit, SymptomsState>(
      buildWhen: (previous, current) =>
          previous is! SymptomsLoaded ||
          current is! SymptomsLoaded ||
          previous.logs != current.logs,
      builder: (context, state) {
        // Computed here, once, so the tile count and the ranked bars can never
        // disagree about what "the last 30 days" contains.
        final trends = state is SymptomsLoaded
            ? _calculator.calculate(
                state.logs,
                from: DateTime.now().subtract(
                  const Duration(days: kDashboardSymptomsWindowDays),
                ),
              )
            : null;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              // No viewPadding term: the shell's navigation bar already
              // covers the bottom inset.
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                DashboardHero(stats: stats, logs: logs),
                const SizedBox(height: AppSpacing.lg),
                CycleStatTiles(
                  stats: stats,
                  symptomCount: trends?.totalEntries,
                  symptomsWindowDays: kDashboardSymptomsWindowDays,
                ),
                const SizedBox(height: AppSpacing.lg),
                const CycleCalendarCard(),
                const SizedBox(height: AppSpacing.lg),
                TopSymptomsCard(
                  trends: trends,
                  failure: state is SymptomsError ? state.failure : null,
                  windowDays: kDashboardSymptomsWindowDays,
                  onRetry: () => context.read<SymptomsCubit>().load(userId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The loaded layout's silhouette — hero, two tile rows, calendar, card — so
/// nothing jumps when the data lands.
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const tile = Expanded(
      child: SkeletonBox(height: 88, radius: AppRadius.card),
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            SkeletonBox(height: 112, radius: AppRadius.card),
            SizedBox(height: AppSpacing.lg),
            Row(children: [tile, SizedBox(width: AppSpacing.md), tile]),
            SizedBox(height: AppSpacing.md),
            Row(children: [tile, SizedBox(width: AppSpacing.md), tile]),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(height: 340, radius: AppRadius.card),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(height: 160, radius: AppRadius.card),
          ],
        ),
      ),
    );
  }
}
