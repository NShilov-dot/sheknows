import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/constants/period.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:sheknows/features/daily_log/presentation/cubit/daily_log_cubit.dart';
import 'package:sheknows/features/daily_log/presentation/cubit/daily_log_state.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _moodLabels = {
  Mood.happy: 'Happy',
  Mood.calm: 'Calm',
  Mood.energetic: 'Energetic',
  Mood.sad: 'Sad',
  Mood.irritable: 'Irritable',
  Mood.anxious: 'Anxious',
};

const _moodEmojis = {
  Mood.happy: '😊',
  Mood.calm: '😌',
  Mood.energetic: '⚡️',
  Mood.sad: '😢',
  Mood.irritable: '😤',
  Mood.anxious: '😰',
};

/// Bottom sheet shown when a calendar day is tapped: period actions
/// (start/end/delete with flow + notes) and the daily check-in
/// (mood + symptoms).
class DayDetailsSheet extends StatelessWidget {
  const DayDetailsSheet({
    super.key,
    required this.day,
    required this.userId,
    required this.logs,
    required this.stats,
    required this.periodCubit,
  });

  final DateTime day;
  final String userId;
  final List<PeriodLogEntity> logs;
  final CycleStats stats;
  final PeriodCubit periodCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DailyLogCubit>()..loadForDate(userId, day),
      child: _SheetBody(
        day: day,
        userId: userId,
        logs: logs,
        stats: stats,
        periodCubit: periodCubit,
      ),
    );
  }
}

class _SheetBody extends StatefulWidget {
  const _SheetBody({
    required this.day,
    required this.userId,
    required this.logs,
    required this.stats,
    required this.periodCubit,
  });

  final DateTime day;
  final String userId;
  final List<PeriodLogEntity> logs;
  final CycleStats stats;
  final PeriodCubit periodCubit;

  @override
  State<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends State<_SheetBody> {
  FlowLevel? _selectedFlow;
  final _notesController = TextEditingController();
  Mood? _mood;
  final _selectedSymptoms = <String>{};

  bool get _isFuture => widget.day.isAfter(DateTime.now());

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today = DateTime.now();

    final covering =
        widget.logs.where((log) => log.coversDay(widget.day)).firstOrNull;
    final ongoing = widget.stats.currentPeriod;
    final canEndHere = ongoing != null &&
        !widget.day.isBefore(ongoing.startDate) &&
        !widget.day.isAfter(today);
    final canStartHere = covering == null && !_isFuture;
    final isPredictedStart = _isSameDay(widget.day, widget.stats.nextPredictedStart);

    String status;
    if (covering != null) {
      final dayNumber = _dateOnly(widget.day)
              .difference(_dateOnly(covering.startDate))
              .inDays +
          1;
      status = covering.isOngoing
          ? 'Bleeding · day $dayNumber of this period'
          : 'Day $dayNumber of a ${covering.durationInDays}-day period';
    } else if (isPredictedStart) {
      status = 'Predicted period start';
    } else {
      final lastStart = _latestStartDate(widget.logs);
      if (lastStart != null &&
          !widget.day.isBefore(lastStart) &&
          !widget.day.isAfter(today)) {
        final cycleDay = _dateOnly(widget.day)
                .difference(_dateOnly(lastStart))
                .inDays +
            1;
        status = 'Cycle day $cycleDay';
      } else if (_isFuture) {
        status = 'Upcoming';
      } else {
        status = 'No data for this day';
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${_weekdayNames[widget.day.weekday - 1]}, '
              '${widget.day.day} ${_monthNames[widget.day.month - 1]}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // -- Period actions ------------------------------------------------
            if (canStartHere) ...[
              Text('Flow', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              _FlowPicker(
                selected: _selectedFlow,
                onSelected: (flow) => setState(() => _selectedFlow = flow),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLength: kPeriodNotesMaxLength,
                decoration: const InputDecoration(
                  hintText: 'Notes (cramps, mood, anything worth remembering)',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _logPeriod,
                icon: const Icon(Icons.water_drop),
                label: const Text('Period started on this day'),
              ),
              const SizedBox(height: 20),
            ],
            if (canEndHere)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: OutlinedButton.icon(
                  onPressed: () => _run(() => widget.periodCubit.endPeriod(widget.day)),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('End period on this day'),
                ),
              ),
            if (covering != null &&
                !covering.id.startsWith('pending-'))
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextButton.icon(
                  onPressed: () =>
                      _run(() => widget.periodCubit.removePeriod(covering.id)),
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                  label: Text(
                    'Delete this period',
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              ),

            // -- Daily check-in -------------------------------------------------
            if (!_isFuture) ...[
              Divider(color: scheme.outline.withValues(alpha: 0.4)),
              const SizedBox(height: 4),
              Text('How do you feel today?', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              BlocConsumer<DailyLogCubit, DailyLogState>(
                listener: (context, state) {
                  if (state is! DailyLogReady) {
                    return;
                  }
                  final log = state.log;
                  if (log != null && _mood == null && _selectedSymptoms.isEmpty) {
                    setState(() {
                      _mood = log.mood;
                      _selectedSymptoms.addAll(log.symptoms);
                      if (log.notes != null && _notesController.text.isEmpty) {
                        _notesController.text = log.notes!;
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is DailyLogLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  if (state is DailyLogError) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        state.failure.message,
                        style: TextStyle(color: scheme.error),
                      ),
                    );
                  }

                  final ready = state is DailyLogReady ? state : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final mood in Mood.values)
                            _MoodChip(
                              emoji: _moodEmojis[mood]!,
                              label: _moodLabels[mood]!,
                              selected: _mood == mood,
                              onTap: () => setState(() {
                                _mood = _mood == mood ? null : mood;
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Symptoms', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final symptom in kSymptomCatalog)
                            FilterChip(
                              label: Text(symptom),
                              selected:
                                  _selectedSymptoms.contains(symptom),
                              onSelected: (selected) => setState(() {
                                selected
                                    ? _selectedSymptoms.add(symptom)
                                    : _selectedSymptoms.remove(symptom);
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonalIcon(
                        onPressed: ready?.isSaving == true
                            ? null
                            : _saveDailyLog,
                        icon: ready?.isSaving == true
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.favorite_outline),
                        label: Text(
                          ready?.log == null
                              ? 'Save check-in'
                              : 'Update check-in',
                        ),
                      ),
                      if (ready?.savedAt == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Saved ✓',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      if (ready?.failure != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            ready!.failure!.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: scheme.error),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _logPeriod() {
    widget.periodCubit.startPeriod(
      widget.day,
      flow: _selectedFlow,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  void _saveDailyLog() {
    context.read<DailyLogCubit>().save(
          mood: _mood,
          symptoms: _selectedSymptoms.toList(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
  }

  void _run(VoidCallback action) {
    action();
    Navigator.of(context).pop();
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

class _FlowPicker extends StatelessWidget {
  const _FlowPicker({required this.selected, required this.onSelected});

  final FlowLevel? selected;
  final ValueChanged<FlowLevel> onSelected;

  static const _labels = {
    FlowLevel.light: 'Light',
    FlowLevel.medium: 'Medium',
    FlowLevel.heavy: 'Heavy',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SegmentedButton<FlowLevel>(
      segments: [
        for (final entry in _labels.entries)
          ButtonSegment(
            value: entry.key,
            label: Text(entry.value),
            icon: Icon(
              Icons.water_drop,
              size: 16,
              color: selected == entry.key ? scheme.onSecondary : null,
            ),
          ),
      ],
      selected: selected == null ? {} : {selected!},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onSelected(selection.first);
        }
      },
      showSelectedIcon: false,
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.secondary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color:
                    selected ? scheme.onSecondaryContainer : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
