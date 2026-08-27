import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/period/presentation/widgets/cycle_calendar_card.dart';
import 'package:sheknows/features/period/presentation/widgets/cycle_insights_card.dart';
import 'package:sheknows/features/period/presentation/widgets/cycle_moon_header.dart';
import 'package:sheknows/features/period/presentation/widgets/period_actions_card.dart';
import 'package:sheknows/features/period/presentation/widgets/period_history_list.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_gate.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class PeriodTrackerPage extends StatelessWidget {
  const PeriodTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      builder: (context, userId) => BlocProvider(
        create: (_) => sl<PeriodCubit>()..load(userId),
        child: const _PeriodTrackerView(),
      ),
    );
  }
}

class _PeriodTrackerView extends StatelessWidget {
  const _PeriodTrackerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).cycleTitle),
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      body: BlocConsumer<PeriodCubit, PeriodState>(
        listenWhen: (previous, current) {
          if (current is! PeriodLoaded || current.mutationFailure == null) {
            return false;
          }
          return previous is! PeriodLoaded ||
              previous.mutationFailure != current.mutationFailure;
        },
        listener: (context, state) {
          if (state is PeriodLoaded && state.mutationFailure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  failureMessage(
                    AppLocalizations.of(context),
                    state.mutationFailure!,
                  ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (state) {
              PeriodInitial() || PeriodLoading() => const _PeriodSkeleton(
                key: ValueKey('loading'),
              ),
              PeriodError(:final failure) => _PeriodErrorView(
                key: const ValueKey('error'),
                failure: failure,
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

/// The error arm of the cycle screen. A bare centred string stranded the user:
/// re-entering /cycle was the only way to re-run [PeriodCubit.load].
class _PeriodErrorView extends StatelessWidget {
  const _PeriodErrorView({super.key, required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: AppIconSize.empty,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              failureMessage(AppLocalizations.of(context), failure),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is! AuthAuthenticated) {
                  return;
                }
                context.read<PeriodCubit>().load(authState.user.id);
              },
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).commonTryAgain),
            ),
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
