import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/constants/period.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/widgets/section_label.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/period/presentation/utils/day_status.dart';
import 'package:sheknows/features/period/presentation/widgets/day_details/day_header.dart';
import 'package:sheknows/features/period/presentation/widgets/day_details/day_symptoms_section.dart';
import 'package:sheknows/features/period/presentation/widgets/day_details/period_actions.dart';

/// Bottom sheet shown when a calendar day is tapped. It offers the period
/// actions that make sense for the day (start / end / delete) and — for days
/// that aren't in the future — an editor for that day's tracking: intimacy,
/// symptoms, mood, and a note.
class DayDetailsSheet extends StatelessWidget {
  const DayDetailsSheet({
    super.key,
    required this.day,
    required this.logs,
    required this.stats,
    required this.dayLog,
    required this.cubit,
    required this.userId,
  });

  final DateTime day;
  final List<PeriodLogEntity> logs;
  final CycleStats stats;

  /// Existing tracking for this day, if any.
  final DayLogEntity? dayLog;
  final PeriodCubit cubit;

  /// Authenticated user, used to scope this day's symptom entries. Null only
  /// in the unlikely window before auth resolves — the symptoms section hides.
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isFuture = day.isAfter(today);

    final covering = logs.where((log) => log.coversDay(day)).firstOrNull;
    final ongoing = stats.currentPeriod;
    final canEndHere = ongoing != null &&
        !day.isBefore(ongoing.startDate) &&
        !day.isAfter(today);
    final canStartHere = covering == null && !isFuture;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DayHeader(
                day: day,
                status: dayStatusLabel(
                  day: day,
                  today: today,
                  logs: logs,
                  stats: stats,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PeriodActions(
                canStartHere: canStartHere,
                canEndHere: canEndHere,
                deletablePeriodId:
                    covering != null && !covering.id.startsWith('pending-')
                        ? covering.id
                        : null,
                onStart: () =>
                    _runPeriodAction(context, () => cubit.startPeriod(day)),
                onEnd: () =>
                    _runPeriodAction(context, () => cubit.endPeriod(day)),
                onDelete: (id) =>
                    _runPeriodAction(context, () => cubit.removePeriod(id)),
              ),
              if (!isFuture)
                _DayTrackingForm(
                  day: day,
                  dayLog: dayLog,
                  cubit: cubit,
                  userId: userId,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void _runPeriodAction(BuildContext context, VoidCallback action) {
  action();
  Navigator.of(context).pop();
}

/// The "How was your day?" editor: intimacy, symptoms, notes and the save /
/// clear buttons. Owns the in-progress edits until they are saved.
class _DayTrackingForm extends StatefulWidget {
  const _DayTrackingForm({
    required this.day,
    required this.dayLog,
    required this.cubit,
    required this.userId,
  });

  final DateTime day;
  final DayLogEntity? dayLog;
  final PeriodCubit cubit;
  final String? userId;

  @override
  State<_DayTrackingForm> createState() => _DayTrackingFormState();
}

class _DayTrackingFormState extends State<_DayTrackingForm> {
  /// Authoritative value used by [_save]; kept in sync by [_IntimacyChips]
  /// without a setState here — nothing in this build reads it.
  SexualActivity? _sexualActivity;
  late TextEditingController _notes;

  /// Set the moment a save is dispatched so a double-tap in the same frame
  /// cannot fire the mutation twice before the sheet finishes popping.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final log = widget.dayLog;
    _sexualActivity = log?.sexualActivity;
    _notes = TextEditingController(text: log?.notes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (_saving) return;
    setState(() => _saving = true);
    widget.cubit.saveDayLog(
      widget.day,
      sexualActivity: _sexualActivity,
      notes: _notes.text,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.lg),
        Text('How was your day?', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),

        const SectionLabel('Intimacy', icon: Icons.favorite_border),
        const SizedBox(height: AppSpacing.sm),
        _IntimacyChips(
          initial: _sexualActivity,
          onChanged: (value) => _sexualActivity = value,
        ),
        const SizedBox(height: AppSpacing.lg),

        if (widget.userId != null) ...[
          DaySymptomsSection(day: widget.day, userId: widget.userId!),
          const SizedBox(height: AppSpacing.lg),
        ],

        const SectionLabel('Notes', icon: Icons.notes_outlined),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _notes,
          minLines: 1,
          maxLines: 3,
          maxLength: kDayNotesMaxLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Anything you want to remember about today',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // The cubit drops a save while another mutation is in flight, so the
        // buttons follow its own guard instead of failing silently.
        BlocBuilder<PeriodCubit, PeriodState>(
          bloc: widget.cubit,
          builder: (context, state) {
            final busy =
                _saving || state is! PeriodLoaded || state.isLoading;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: busy ? null : _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Save day'),
                ),
                if (widget.dayLog != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => _runPeriodAction(context,
                            () => widget.cubit.deleteDayLog(widget.dayLog!.id)),
                    child: const Text('Clear this day'),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// The intimacy chip row. Holds its own selection so a tap rebuilds only the
/// [Wrap] instead of the whole tracking form (notes field included).
class _IntimacyChips extends StatefulWidget {
  const _IntimacyChips({required this.initial, required this.onChanged});

  final SexualActivity? initial;
  final ValueChanged<SexualActivity?> onChanged;

  @override
  State<_IntimacyChips> createState() => _IntimacyChipsState();
}

class _IntimacyChipsState extends State<_IntimacyChips> {
  late SexualActivity? _selected = widget.initial;

  @override
  void didUpdateWidget(_IntimacyChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _selected = widget.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final activity in SexualActivity.values)
          ChoiceChip(
            label: Text(_sexualActivityLabel(activity)),
            selected: _selected == activity,
            onSelected: (selected) {
              setState(() => _selected = selected ? activity : null);
              widget.onChanged(_selected);
            },
          ),
      ],
    );
  }
}

String _sexualActivityLabel(SexualActivity activity) => switch (activity) {
      SexualActivity.protected => 'Protected',
      SexualActivity.unprotected => 'Unprotected',
    };
