import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/period/presentation/widgets/cycle_calendar.dart';
import 'package:sheknows/features/period/presentation/widgets/day_details_sheet.dart';
import 'package:sheknows/features/period/presentation/widgets/moon_cycle_indicator.dart';

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

  void _onDaySelected(BuildContext context, DateTime day) {
    final cubit = context.read<PeriodCubit>();
    final state = cubit.state;
    if (state is! PeriodLoaded) {
      return;
    }
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => DayDetailsSheet(
        day: day,
        logs: state.logs,
        stats: state.stats,
        dayLog: state.dayLogFor(day),
        cubit: cubit,
        userId: userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BlocSelector<PeriodCubit, PeriodState, CycleStats?>(
          selector: (state) => state is PeriodLoaded ? state.stats : null,
          builder: (context, stats) {
            if (stats == null || stats.currentCycleDay == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MoonCycleIndicator(stats: stats),
            );
          },
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            child: BlocBuilder<PeriodCubit, PeriodState>(
              builder: (context, state) {
                final loaded = state is PeriodLoaded ? state : null;
                return CycleCalendar(
                  month:
                      loaded?.displayedMonth ?? DateTime.now(),
                  logs: loaded?.logs ?? const [],
                  dayLogs: loaded?.dayLogs ?? const [],
                  stats: loaded?.stats,
                  onDaySelected: (day) => _onDaySelected(context, day),
                  onMonthChanged: (month) =>
                      context.read<PeriodCubit>().goToMonth(month),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _StatsCard(),
        const SizedBox(height: 16),
        const _ActionsCard(),
        const SizedBox(height: 24),
        Text(
          'History',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const _HistoryList(),
      ],
    );
  }
}

// -- Stats -------------------------------------------------------------------

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  static String _formatDate(DateTime date) =>
      '${date.day} ${_statsMonthNames[date.month - 1]} ${date.year}';

  static const _statsMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PeriodCubit, PeriodState, CycleStats?>(
      selector: (state) => state is PeriodLoaded ? state.stats : null,
      builder: (context, stats) {
        if (stats == null) {
          return const SizedBox.shrink();
        }

        final items = <(String, String)>[
          ('Logged periods', '${stats.periodCount}'),
          if (stats.averageCycleLength != null)
            ('Avg cycle length', '${stats.averageCycleLength} days'),
          if (stats.averagePeriodLength != null)
            ('Avg period length', '${stats.averagePeriodLength} days'),
          if (stats.currentPeriod != null)
            (
              'Current period',
              'Day ${stats.currentPeriod!.durationInDays} of bleeding',
            ),
          if (stats.hasPrediction)
            ('Next period expected', _formatDate(stats.nextPredictedStart!)),
        ];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Insights', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.$1),
                        Text(
                          item.$2,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                if (!stats.hasPrediction && stats.periodCount < 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Log at least two periods to see cycle predictions.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -- Quick actions -----------------------------------------------------------

class _ActionsCard extends StatelessWidget {
  const _ActionsCard();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PeriodCubit, PeriodState, CycleStats?>(
      selector: (state) => state is PeriodLoaded ? state.stats : null,
      builder: (context, stats) {
        if (stats == null) {
          return const SizedBox.shrink();
        }

        final ongoing = stats.currentPeriod;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: ongoing == null
                      ? () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: now.subtract(const Duration(days: 365 * 2)),
                            lastDate: now,
                            helpText: 'When did your period start?',
                          );
                          if (picked != null && context.mounted) {
                            context.read<PeriodCubit>().startPeriod(picked);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.water_drop),
                  label: const Text('My period started today'),
                ),
                if (ongoing != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<PeriodCubit>().endPeriod(DateTime.now()),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('End period today'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// -- History -----------------------------------------------------------------

class _HistoryList extends StatelessWidget {
  const _HistoryList();

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
              _HistoryTile(log: log),
          ],
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.log});

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
