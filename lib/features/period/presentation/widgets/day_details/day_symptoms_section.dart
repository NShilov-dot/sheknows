import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/widgets/section_label.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_log_sheet.dart';

/// This day's symptom entries, backed by its own page-scoped [SymptomsCubit]
/// (a fresh instance loaded to just this day's window).
class DaySymptomsSection extends StatelessWidget {
  const DaySymptomsSection(
      {super.key, required this.day, required this.userId});

  final DateTime day;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final from = DateTime(day.year, day.month, day.day);
    final to = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
    return BlocProvider(
      create: (_) => sl<SymptomsCubit>()..load(userId, from: from, to: to),
      // This cubit is a fresh page-scoped instance, so SymptomsPage's snack bar
      // listener never sees its failures — mirror it here.
      child: BlocListener<SymptomsCubit, SymptomsState>(
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
        child: _DaySymptomsBody(day: day, userId: userId, from: from, to: to),
      ),
    );
  }
}

class _DaySymptomsBody extends StatelessWidget {
  const _DaySymptomsBody({
    required this.day,
    required this.userId,
    required this.from,
    required this.to,
  });

  final DateTime day;
  final String userId;
  final DateTime from;
  final DateTime to;

  void _openSheet(BuildContext context, {SymptomLogEntity? existing}) {
    final cubit = context.read<SymptomsCubit>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SymptomLogSheet(
        cubit: cubit,
        existing: existing,
        initialDate: existing == null ? day : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: SectionLabel('Symptoms', icon: Icons.healing_outlined),
            ),
            TextButton.icon(
              onPressed: () => _openSheet(context),
              icon: const Icon(Icons.add, size: AppIconSize.md),
              label: const Text('Log'),
            ),
          ],
        ),
        // The placeholder matches the empty-state line, but a day with
        // entries is 48px taller per ListTile — absorb that instead of
        // shoving the notes field and Save button down in one frame.
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: BlocBuilder<SymptomsCubit, SymptomsState>(
            builder: (context, state) {
              // Branch on the state: an in-flight or failed load must not read
              // as "nothing logged".
              if (state is SymptomsInitial || state is SymptomsLoading) {
                return const _SymptomsPlaceholder();
              }
              if (state is SymptomsError) {
                return _SymptomsErrorRow(
                  message: failureMessage(state.failure),
                  onRetry: () => context
                      .read<SymptomsCubit>()
                      .load(userId, from: from, to: to),
                );
              }
              final logs = state is SymptomsLoaded
                  ? state.logs
                  : const <SymptomLogEntity>[];
              if (logs.isEmpty) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No symptoms logged for this day',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final log in logs)
                    ListTile(
                      key: ValueKey(log.id),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(symptomTypeLabel(log.type)),
                      subtitle: Text(
                        '${symptomSeverityLabel(log.severity)} · '
                        '${TimeOfDay.fromDateTime(log.loggedAt).format(context)}',
                      ),
                      onTap: () => _openSheet(context, existing: log),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Stand-in for the symptom list while it loads: one bar the height of the
/// "no symptoms" line, so the section does not jump when data arrives.
class _SymptomsPlaceholder extends StatelessWidget {
  const _SymptomsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 180,
        height: AppSpacing.xl,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.swatch),
        ),
      ),
    );
  }
}

/// Shown when this day's symptoms could not be loaded, with a way back.
class _SymptomsErrorRow extends StatelessWidget {
  const _SymptomsErrorRow({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: AppIconSize.md,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
