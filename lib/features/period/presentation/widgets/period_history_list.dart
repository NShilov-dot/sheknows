import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/period/presentation/utils/period_labels.dart';

class PeriodHistoryList extends StatelessWidget {
  const PeriodHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PeriodCubit, PeriodState, List<PeriodLogEntity>?>(
      selector: (state) => state is PeriodLoaded ? state.logs : null,
      builder: (context, logs) {
        final items = logs ?? const <PeriodLogEntity>[];
        if (items.isEmpty) {
          return const _HistoryEmptyState();
        }

        return Column(
          children: [
            for (final log in items)
              PeriodHistoryTile(key: ValueKey(log.id), log: log),
          ],
        );
      },
    );
  }
}

class PeriodHistoryTile extends StatelessWidget {
  const PeriodHistoryTile({super.key, required this.log});

  final PeriodLogEntity log;

  String get _dateRange {
    final start = '${log.startDate.day}/${log.startDate.month}';
    if (log.isOngoing) {
      return '$start – ongoing';
    }
    return '$start – ${log.endDate!.day}/${log.endDate!.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isPending = log.id.startsWith('pending-');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: !isPending,
      leading: Icon(
        Icons.water_drop,
        color: log.isOngoing
            ? scheme.primary
            : scheme.primary.withValues(alpha: AppAlpha.muted),
      ),
      title: Text(_dateRange),
      subtitle: Text(
        '${log.durationInDays} day${log.durationInDays == 1 ? '' : 's'}'
        '${log.flow == null ? '' : ' · ${flowLevelLabel(log.flow!)} flow'}'
        '${isPending ? ' · saving…' : ''}',
      ),
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
              tooltip: 'Period options',
              itemBuilder: (menuContext) => [
                if (!log.isOngoing)
                  const PopupMenuItem(
                    value: 'reopen',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.undo),
                      title: Text('Reopen (ongoing)'),
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline),
                    title: Text('Delete'),
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
              'No periods logged yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap "My period started today" to start tracking.',
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
