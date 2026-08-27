import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_history_list.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_trends_body.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptoms_error_view.dart';

class SymptomTrendsPage extends StatelessWidget {
  const SymptomTrendsPage({super.key});

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
          create: (_) => sl<SymptomsCubit>()..load(userId),
          // This page owns its cubit instance, so its own retry is the only
          // thing that can re-drive the load.
          child: _TrendsView(userId: userId),
        );
      },
    );
  }
}

class _TrendsView extends StatelessWidget {
  const _TrendsView({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trends'),
        leading: BackButton(onPressed: () => context.go('/symptoms')),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: 'By cycle phase',
            onPressed: () => context.go('/symptom-phases'),
          ),
        ],
      ),
      body: BlocBuilder<SymptomsCubit, SymptomsState>(
        builder: (context, state) {
          // Keyed branches so the skeleton cross-fades into the trends body.
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (state) {
              SymptomsInitial() || SymptomsLoading() =>
                const _TrendsSkeleton(key: ValueKey('loading')),
              SymptomsError(:final failure) => SymptomsErrorView(
                  key: const ValueKey('error'),
                  failure: failure,
                  onRetry: () => context.read<SymptomsCubit>().load(userId),
                ),
              SymptomsLoaded(:final logs) => SymptomTrendsBody(
                  key: const ValueKey('loaded'),
                  logs: logs,
                ),
            },
          );
        },
      ),
    );
  }
}

/// Rough outline of [SymptomTrendsBody] — range selector, summary card, two
/// bar sections — so the first paint does not jump when the data lands.
class _TrendsSkeleton extends StatelessWidget {
  const _TrendsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            SkeletonBox(height: 40, radius: AppRadius.button),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(height: 72, radius: AppRadius.card),
            SizedBox(height: AppSpacing.xl),
            SkeletonBox(width: 140, height: 14),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 20),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 20),
            SizedBox(height: AppSpacing.xl),
            SkeletonBox(width: 110, height: 14),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 20),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 20),
          ],
        ),
      ),
    );
  }
}
