import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
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

class PeriodTrackerPage extends StatelessWidget {
  const PeriodTrackerPage({super.key});

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
          create: (_) => sl<PeriodCubit>()..load(userId),
          child: const _PeriodTrackerView(),
        );
      },
    );
  }
}

class _PeriodTrackerView extends StatelessWidget {
  const _PeriodTrackerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
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
              SnackBar(content: Text(state.mutationFailure!.message)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            PeriodInitial() || PeriodLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            PeriodError(:final failure) => Center(child: Text(failure.message)),
            PeriodLoaded() => const _PeriodBody(),
          };
        },
      ),
    );
  }
}

class _PeriodBody extends StatelessWidget {
  const _PeriodBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const CycleMoonHeader(),
        const CycleCalendarCard(),
        const SizedBox(height: AppSpacing.lg),
        const CycleInsightsCard(),
        const SizedBox(height: AppSpacing.lg),
        const PeriodActionsCard(),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'History',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        const PeriodHistoryList(),
      ],
    );
  }
}
