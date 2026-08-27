import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_log_sheet.dart';

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
          child: const _SymptomsView(),
        );
      },
    );
  }
}

class _SymptomsView extends StatelessWidget {
  const _SymptomsView();

  void _openLogSheet(BuildContext context, {SymptomLogEntity? existing}) {
    final cubit = context.read<SymptomsCubit>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
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
              SnackBar(content: Text(state.mutationFailure!.message)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            SymptomsInitial() || SymptomsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            SymptomsError(:final failure) =>
              Center(child: Text(failure.message)),
            SymptomsLoaded(:final logs) => logs.isEmpty
                ? const _EmptyState()
                : _SymptomsList(
                    logs: logs,
                    onTap: (log) => _openLogSheet(context, existing: log),
                  ),
          };
        },
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.healing_outlined,
                size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'No symptoms logged yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
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

class _SymptomsList extends StatelessWidget {
  const _SymptomsList({required this.logs, required this.onTap});

  final List<SymptomLogEntity> logs;
  final ValueChanged<SymptomLogEntity> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final showHeader =
            index == 0 || !_sameDay(logs[index - 1].loggedAt, log.loggedAt);
        return Column(
          key: ValueKey(log.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) _DateHeader(date: log.loggedAt),
            _SymptomTile(log: log, onTap: () => onTap(log)),
          ],
        );
      },
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        MaterialLocalizations.of(context).formatFullDate(date),
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _SymptomTile extends StatelessWidget {
  const _SymptomTile({required this.log, required this.onTap});

  final SymptomLogEntity log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = TimeOfDay.fromDateTime(log.loggedAt).format(context);
    final notes = log.notes?.trim();
    return ListTile(
      onTap: onTap,
      title: Text(symptomTypeLabel(log.type)),
      subtitle: Text(
        [
          '${symptomSeverityLabel(log.severity)} · $time',
          if (notes != null && notes.isNotEmpty) notes,
        ].join('\n'),
      ),
      isThreeLine: notes != null && notes.isNotEmpty,
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
