import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/di/injection.dart';
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
  const DaySymptomsSection({super.key, required this.day, required this.userId});

  final DateTime day;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final from = DateTime(day.year, day.month, day.day);
    final to = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
    return BlocProvider(
      create: (_) => sl<SymptomsCubit>()..load(userId, from: from, to: to),
      child: _DaySymptomsBody(day: day),
    );
  }
}

class _DaySymptomsBody extends StatelessWidget {
  const _DaySymptomsBody({required this.day});

  final DateTime day;

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
        BlocBuilder<SymptomsCubit, SymptomsState>(
          builder: (context, state) {
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
      ],
    );
  }
}
