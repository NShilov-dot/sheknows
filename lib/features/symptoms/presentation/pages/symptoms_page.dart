import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/core/widgets/skeleton_box.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_history_list.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_log_sheet.dart';
import 'package:sheknows/core/widgets/load_error_view.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_gate.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class SymptomsPage extends StatelessWidget {
  const SymptomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The cubit is AppShell's, shared with the dashboard; the id is what the
    // error state's retry re-runs the load with.
    return AuthGate(
      builder: (context, userId) => _SymptomsView(userId: userId),
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.symptomsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: l10n.symptomTrendsTitle,
            onPressed: () => context.go('/symptom-trends'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLogSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.symptomLogAction),
      ),
      // Mutation failures are announced by AppShell, which owns the cubit.
      body: BlocBuilder<SymptomsCubit, SymptomsState>(
        builder: (context, state) {
          // Keyed branches so the skeleton cross-fades into the list instead
          // of being replaced in a single frame.
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (state) {
              SymptomsInitial() ||
              SymptomsLoading() =>
                const _SymptomsSkeleton(key: ValueKey('loading')),
              SymptomsError(:final failure) => LoadErrorView(
                  key: const ValueKey('error'),
                  failure: failure,
                  onRetry: () => context.read<SymptomsCubit>().load(userId),
                ),
              SymptomsLoaded(:final logs) => logs.isEmpty
                  ? const _EmptyState(key: ValueKey('empty'))
                  : SymptomHistoryList(
                      key: const ValueKey('list'),
                      logs: logs,
                      onTap: (log) => _openLogSheet(context, existing: log),
                    ),
            },
          );
        },
      ),
    );
  }
}

/// Stand-in for [SymptomHistoryList] while the first load runs: a date header
/// and a few tile-shaped blocks, so the list does not appear from nowhere the
/// way a centred spinner makes it.
class _SymptomsSkeleton extends StatelessWidget {
  const _SymptomsSkeleton({super.key});

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
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.healing_outlined,
                size: AppIconSize.empty,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.symptomsEmptyTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.symptomsEmptyBody,
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
