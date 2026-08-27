import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class PeriodHistoryList extends StatelessWidget {
  const PeriodHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PeriodCubit, PeriodState, (List<PeriodLogEntity>, bool)>(
      selector: (state) => state is PeriodLoaded
          ? (state.logs, state.isLoading)
          : (const <PeriodLogEntity>[], false),
      builder: (context, selected) {
        final (items, isLoading) = selected;
        if (items.isEmpty) {
          return const _HistoryEmptyState();
        }

        return Column(
          children: [
            for (final log in items)
              PeriodHistoryTile(
                key: ValueKey(log.id),
                log: log,
                busy: isLoading,
              ),
          ],
        );
      },
    );
  }
}

class PeriodHistoryTile extends StatelessWidget {
  const PeriodHistoryTile({
    super.key,
    required this.log,
    this.busy = false,
  });

  final PeriodLogEntity log;

  /// True while another period mutation is in flight. PeriodCubit drops
  /// reopen/delete silently in that window, so the menu is disabled rather
  /// than left live to buzz and do nothing.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final scheme = theme.colorScheme;
    final isPending = log.id.startsWith('pending-');

    final subtitleParts = [
      l10n.commonDaysCount(log.durationInDays()),
      if (log.flow != null)
        switch (log.flow!) {
          FlowLevel.light => l10n.cycleHistoryFlowLight,
          FlowLevel.medium => l10n.cycleHistoryFlowMedium,
          FlowLevel.heavy => l10n.cycleHistoryFlowHeavy,
        },
      if (isPending) l10n.cycleHistorySaving,
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: !isPending,
      leading: Icon(
        Icons.water_drop,
        color: log.isOngoing
            ? scheme.primary
            : scheme.primary.withValues(alpha: AppAlpha.muted),
      ),
      title: Text(
        log.isOngoing
            ? l10n.cycleHistoryRangeOngoing(log.startDate)
            : l10n.cycleHistoryRange(log.startDate, log.endDate!),
      ),
      subtitle: Text(subtitleParts.join(' · ')),
      // A 'pending-' row has no server id yet, so PeriodCubit.removePeriod
      // early-returns and the menu's Delete silently did nothing. Show that
      // it is still saving instead of offering actions that no-op.
      trailing: isPending
          ? const SizedBox(
              width: AppIconSize.md,
              height: AppIconSize.md,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : PopupMenuButton<String>(
              // Defaults to MaterialLocalizations' generic "Show menu";
              // name what it actually opens.
              tooltip: l10n.cycleHistoryMenuTooltip,
              enabled: !busy,
              itemBuilder: (menuContext) => [
                if (!log.isOngoing)
                  PopupMenuItem(
                    value: 'reopen',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.undo),
                      title: Text(l10n.cycleHistoryReopen),
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_outline),
                    title: Text(l10n.commonDelete),
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'reopen':
                    HapticFeedback.selectionClick();
                    context.read<PeriodCubit>().reopenPeriod(log.id);
                  case 'delete':
                    HapticFeedback.mediumImpact();
                    context.read<PeriodCubit>().removePeriod(log.id);
                }
              },
            ),
    );
  }
}

/// Matches the designed empty state on the symptoms screen: icon, title, and
/// one line pointing at the action that fills the list.
class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

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
            Icon(
              Icons.water_drop_outlined,
              size: AppIconSize.empty,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.cycleHistoryEmptyTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.cycleHistoryEmptyBody,
              textAlign: TextAlign.center,
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
