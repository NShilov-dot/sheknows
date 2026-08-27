import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';

class PeriodHistoryList extends StatelessWidget {
  const PeriodHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PeriodCubit, PeriodState, List<PeriodLogEntity>?>(
      selector: (state) => state is PeriodLoaded ? state.logs : null,
      builder: (context, logs) {
        final items = logs ?? const <PeriodLogEntity>[];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No periods logged yet.')),
          );
        }

        return Column(
          children: [
            for (final log in items)
              PeriodHistoryTile(log: log),
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
    final start =
        '${log.startDate.day}/${log.startDate.month}';
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
        color: log.isOngoing ? scheme.primary : scheme.primary.withValues(alpha: 0.6),
      ),
      title: Text(_dateRange),
      subtitle: Text(
        '${log.durationInDays} day${log.durationInDays == 1 ? '' : 's'}'
        '${log.flow == null ? '' : ' · ${log.flow!.name} flow'}'
        '${isPending ? ' · saving…' : ''}',
      ),
      trailing: PopupMenuButton<String>(
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
              context.read<PeriodCubit>().reopenPeriod(log.id);
            case 'delete':
              context.read<PeriodCubit>().removePeriod(log.id);
          }
        },
      ),
    );
  }
}
