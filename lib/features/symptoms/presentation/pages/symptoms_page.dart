import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_history_list.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_log_sheet.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptoms_error_view.dart';

class SymptomsPage extends StatelessWidget {
  const SymptomsPage({super.key});

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
          // The id the error state's retry re-runs the load with.
          child: _SymptomsView(userId: userId),
        );
      },
    );
  }
}

class _SymptomsView extends StatelessWidget {
  const _SymptomsView({required this.userId});

  final String userId;

  void _openLogSheet(BuildContext context, {SymptomLogEntity? existing}) {
    final cubit = context.read<SymptomsCubit>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SymptomLogSheet(cubit: cubit, existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptoms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'Trends',
            onPressed: () => context.go('/symptom-trends'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLogSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Log'),
      ),
      body: BlocConsumer<SymptomsCubit, SymptomsState>(
        listenWhen: (previous, current) {
          if (current is! SymptomsLoaded || current.mutationFailure == null) {
            return false;
          }
          return previous is! SymptomsLoaded ||
              previous.mutationFailure != current.mutationFailure;
        },
        listener: (context, state) {
          if (state is SymptomsLoaded && state.mutationFailure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failureMessage(state.mutationFailure!))),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            SymptomsInitial() || SymptomsLoading() => const _SymptomsSkeleton(),
            SymptomsError(:final failure) => SymptomsErrorView(
                failure: failure,
                onRetry: () => context.read<SymptomsCubit>().load(userId),
              ),
            SymptomsLoaded(:final logs) => logs.isEmpty
                ? const _EmptyState()
                : SymptomHistoryList(
                    logs: logs,
                    onTap: (log) => _openLogSheet(context, existing: log),
                  ),
          };
        },
      ),
    );
  }
}

/// Stand-in for [SymptomHistoryList] while the first load runs: a date header
/// and a few tile-shaped blocks, so the list does not appear from nowhere the
/// way a centred spinner makes it.
class _SymptomsSkeleton extends StatelessWidget {
  const _SymptomsSkeleton();

  // Varied widths read as content rather than as a repeated pattern.
  static const _titleWidths = [140.0, 96.0, 168.0, 120.0, 108.0];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: SkeletonBox(width: 200, height: 16),
            ),
            for (final width in _titleWidths)
              SymptomTileSkeleton(titleWidth: width),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.healing_outlined,
                size: AppIconSize.empty, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No symptoms logged yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap Log to record how you feel.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
