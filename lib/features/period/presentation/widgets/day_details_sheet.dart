import 'package:flutter/material.dart';
import 'package:sheknows/core/constants/period.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Bottom sheet shown when a calendar day is tapped. It offers the period
/// actions that make sense for the day (start / end / delete) and — for days
/// that aren't in the future — an editor for that day's tracking: intimacy,
/// symptoms, mood, and a note.
class DayDetailsSheet extends StatefulWidget {
  const DayDetailsSheet({
    super.key,
    required this.day,
    required this.logs,
    required this.stats,
    required this.dayLog,
    required this.cubit,
  });

  final DateTime day;
  final List<PeriodLogEntity> logs;
  final CycleStats stats;

  /// Existing tracking for this day, if any.
  final DayLogEntity? dayLog;
  final PeriodCubit cubit;

  @override
  State<DayDetailsSheet> createState() => _DayDetailsSheetState();
}

class _DayDetailsSheetState extends State<DayDetailsSheet> {
  SexualActivity? _sexualActivity;
  late Set<Symptom> _symptoms;
  Mood? _mood;
  late TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final log = widget.dayLog;
    _sexualActivity = log?.sexualActivity;
    _symptoms = {...?log?.symptoms};
    _mood = log?.mood;
    _notes = TextEditingController(text: log?.notes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    widget.cubit.saveDayLog(
      widget.day,
      sexualActivity: _sexualActivity,
      symptoms: _symptoms,
      mood: _mood,
      notes: _notes.text,
    );
    Navigator.of(context).pop();
  }

  void _runPeriodAction(VoidCallback action) {
    action();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final day = widget.day;
    final today = DateTime.now();
    final isFuture = day.isAfter(today);

    final covering = widget.logs.where((log) => log.coversDay(day)).firstOrNull;
    final ongoing = widget.stats.currentPeriod;
    final canEndHere = ongoing != null &&
        !day.isBefore(ongoing.startDate) &&
        !day.isAfter(today);
    final canStartHere = covering == null && !isFuture;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${_weekdayNames[day.weekday - 1]}, '
                '${day.day} ${_monthNames[day.month - 1]} ${day.year}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _statusFor(day),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // -- Period actions -----------------------------------------
              if (canStartHere)
                FilledButton.icon(
                  onPressed: () =>
                      _runPeriodAction(() => widget.cubit.startPeriod(day)),
                  icon: const Icon(Icons.water_drop),
                  label: const Text('Period started on this day'),
                ),
              if (canEndHere) ...[
                if (canStartHere) const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      _runPeriodAction(() => widget.cubit.endPeriod(day)),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('End period on this day'),
                ),
              ],
              if (covering != null && !covering.id.startsWith('pending-')) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _runPeriodAction(
                      () => widget.cubit.removePeriod(covering.id)),
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                  label: Text(
                    'Delete this period',
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              ],

              // -- Daily tracking -----------------------------------------
              if (!isFuture) ...[
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Text('How was your day?', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),

                _SectionLabel('Intimacy', icon: Icons.favorite_border),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final activity in SexualActivity.values)
                      ChoiceChip(
                        label: Text(_sexualActivityLabel(activity)),
                        selected: _sexualActivity == activity,
                        onSelected: (selected) => setState(
                          () => _sexualActivity = selected ? activity : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                _SectionLabel('Symptoms', icon: Icons.healing_outlined),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final symptom in Symptom.values)
                      FilterChip(
                        label: Text(_symptomLabel(symptom)),
                        selected: _symptoms.contains(symptom),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _symptoms.add(symptom);
                          } else {
                            _symptoms.remove(symptom);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                _SectionLabel('Mood', icon: Icons.mood),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final mood in Mood.values)
                      ChoiceChip(
                        label: Text(_moodLabel(mood)),
                        selected: _mood == mood,
                        onSelected: (selected) =>
                            setState(() => _mood = selected ? mood : null),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                _SectionLabel('Notes', icon: Icons.notes_outlined),
                const SizedBox(height: 8),
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
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Save day'),
                ),
                if (widget.dayLog != null) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => _runPeriodAction(
                        () => widget.cubit.deleteDayLog(widget.dayLog!.id)),
                    child: const Text('Clear this day'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _statusFor(DateTime day) {
    final today = DateTime.now();
    final isFuture = day.isAfter(today);
    final covering = widget.logs.where((log) => log.coversDay(day)).firstOrNull;
    if (covering != null) {
      final dayNumber = _dateOnly(day).difference(_dateOnly(covering.startDate)).inDays + 1;
      return covering.isOngoing
          ? 'Bleeding · day $dayNumber of this period'
          : 'Day $dayNumber of a ${covering.durationInDays}-day period';
    }
    if (_isSameDay(day, widget.stats.nextPredictedStart)) {
      return 'Predicted period start';
    }
    final lastStart =
        widget.stats.currentCycleDay == null ? null : _latestStartDate(widget.logs);
    if (lastStart != null && !day.isBefore(lastStart) && !day.isAfter(today)) {
      final cycleDay =
          _dateOnly(day).difference(_dateOnly(lastStart)).inDays + 1;
      return 'Cycle day $cycleDay';
    }
    return isFuture ? 'Upcoming' : 'No period data for this day';
  }

  static DateTime? _latestStartDate(List<PeriodLogEntity> logs) {
    DateTime? latest;
    for (final log in logs) {
      if (latest == null || log.startDate.isAfter(latest)) {
        latest = log.startDate;
      }
    }
    return latest;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

String _sexualActivityLabel(SexualActivity activity) => switch (activity) {
      SexualActivity.protected => 'Protected',
      SexualActivity.unprotected => 'Unprotected',
    };

String _symptomLabel(Symptom symptom) => switch (symptom) {
      Symptom.cramps => 'Cramps',
      Symptom.headache => 'Headache',
      Symptom.bloating => 'Bloating',
      Symptom.tenderBreasts => 'Tender breasts',
      Symptom.backache => 'Backache',
      Symptom.fatigue => 'Fatigue',
      Symptom.acne => 'Acne',
      Symptom.nausea => 'Nausea',
      Symptom.cravings => 'Cravings',
    };

String _moodLabel(Mood mood) => switch (mood) {
      Mood.happy => 'Happy',
      Mood.calm => 'Calm',
      Mood.energetic => 'Energetic',
      Mood.sensitive => 'Sensitive',
      Mood.sad => 'Sad',
      Mood.anxious => 'Anxious',
      Mood.irritable => 'Irritable',
      Mood.tired => 'Tired',
    };
