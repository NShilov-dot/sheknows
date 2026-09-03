import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/widgets/inline_error_row.dart';
import 'package:sheknows/core/widgets/section_label.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_log_sheet.dart';
import 'package:sheknows/core/utils/date_only.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// This day's symptom entries, backed by its own page-scoped [SymptomsCubit]
/// (a fresh instance loaded to just this day's window).
class DaySymptomsSection extends StatelessWidget {
  const DaySymptomsSection(
      {super.key, required this.day, required this.userId});

  final DateTime day;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final from = day.dateOnly;
    final to = day.endOfDay;
    return BlocProvider(
      create: (_) => sl<SymptomsCubit>()..load(userId, from: from, to: to),
      // Deliberately NOT a snack-bar listener. This section only ever renders
      // inside a showModalBottomSheet route, and ScaffoldMessenger.of resolves
      // to the app-level messenger, which paints into the page's Scaffold —
      // underneath this sheet and its barrier. A mutation failure raised here
      // is reported inline in _DaySymptomsBody instead, where it is visible.
      child: _DaySymptomsBody(day: day, userId: userId, from: from, to: to),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SectionLabel(
                l10n.symptomsTitle,
                icon: Icons.healing_outlined,
              ),
            ),
            TextButton.icon(
              onPressed: () => _openSymptomSheet(context, day: day),
              icon: const Icon(Icons.add, size: AppIconSize.md),
              label: Text(l10n.symptomLogAction),
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
                return InlineErrorRow(
                  message: failureMessage(l10n, state.failure),
                  onRetry: () => context
                      .read<SymptomsCubit>()
                      .load(userId, from: from, to: to),
                );
              }
              final mutationFailure =
                  state is SymptomsLoaded ? state.mutationFailure : null;
              final logs = state is SymptomsLoaded
                  ? state.logs
                  : const <SymptomLogEntity>[];
              if (mutationFailure != null) {
                // A failed add/edit/delete from this sheet. Inline, above
                // whatever did survive, because a snack bar would land behind
                // the sheet.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InlineErrorRow(
                      message: failureMessage(l10n, mutationFailure),
                      onRetry: () => context
                          .read<SymptomsCubit>()
                          .load(userId, from: from, to: to),
                    ),
                    if (logs.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _SymptomLines(logs: logs, day: day),
                    ],
                  ],
                );
              }
              if (logs.isEmpty) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.cycleDayNoSymptoms,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return _SymptomLines(logs: logs, day: day);
            },
          ),
        ),
      ],
    );
  }
}

/// Opens the symptom log sheet over the day sheet, seeded with this day.
void _openSymptomSheet(
  BuildContext context, {
  required DateTime day,
  SymptomLogEntity? existing,
}) {
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

/// This day's symptom entries, one tappable line each.
class _SymptomLines extends StatelessWidget {
  const _SymptomLines({required this.logs, required this.day});

  final List<SymptomLogEntity> logs;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (final log in logs)
          ListTile(
            key: ValueKey(log.id),
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(symptomTypeLabel(l10n, log.type)),
            subtitle: Text(
              l10n.symptomHistoryTileSubtitle(
                symptomSeverityLabel(l10n, log.severity),
                TimeOfDay.fromDateTime(log.loggedAt).format(context),
              ),
            ),
            onTap: () => _openSymptomSheet(context, day: day, existing: log),
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
