import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/constants/symptoms.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/widgets/section_label.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';

/// Bottom sheet for adding or editing a single symptom entry. Shared between
/// the dedicated symptoms page (new entry, free date/time) and the period day
/// details sheet (new entry pre-filled to that day). Pass [existing] to edit.
class SymptomLogSheet extends StatefulWidget {
  const SymptomLogSheet({
    super.key,
    required this.cubit,
    this.existing,
    this.initialDate,
  });

  final SymptomsCubit cubit;

  /// When non-null the sheet edits this entry instead of creating one.
  final SymptomLogEntity? existing;

  /// Calendar day to pre-fill for a new entry (time defaults to now).
  final DateTime? initialDate;

  @override
  State<SymptomLogSheet> createState() => _SymptomLogSheetState();
}

class _SymptomLogSheetState extends State<SymptomLogSheet> {
  SymptomType? _type;
  SymptomSeverity _severity = SymptomSeverity.moderate;
  late DateTime _dateTime;
  late TextEditingController _notes;

  /// Set the moment a write is dispatched so a double-tap in the same frame
  /// cannot fire the mutation twice before the sheet finishes popping.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.type;
    _severity = existing?.severity ?? SymptomSeverity.moderate;
    final now = DateTime.now();
    _dateTime = existing?.loggedAt ??
        (widget.initialDate == null
            ? now
            : DateTime(
                widget.initialDate!.year,
                widget.initialDate!.month,
                widget.initialDate!.day,
                now.hour,
                now.minute,
              ));
    _notes = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final type = _type;
    if (type == null || _saving) {
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _saving = true);
    if (widget.existing == null) {
      widget.cubit.logSymptom(
        type: type,
        severity: _severity,
        loggedAt: _dateTime,
        notes: _notes.text,
      );
    } else {
      widget.cubit.updateSymptomLog(
        id: widget.existing!.id,
        type: type,
        severity: _severity,
        loggedAt: _dateTime,
        notes: _notes.text,
      );
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    if (_saving) return;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    widget.cubit.deleteSymptomLog(widget.existing!.id);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dateTime.hour,
          _dateTime.minute,
        ));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (picked == null || !mounted) return;
    setState(() => _dateTime = DateTime(
          _dateTime.year,
          _dateTime.month,
          _dateTime.day,
          picked.hour,
          picked.minute,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;

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
              Text(
                isEditing ? 'Edit symptom' : 'Log a symptom',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              for (final category in SymptomCategory.values) ...[
                _CategoryChips(
                  category: category,
                  selected: _type,
                  onSelected: (type) => setState(() => _type = type),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              const SizedBox(height: AppSpacing.xs),
              const SectionLabel('Severity', icon: Icons.thermostat),
              const SizedBox(height: AppSpacing.sm),
              _SeverityChips(
                selected: _severity,
                onSelected: (severity) => setState(() => _severity = severity),
              ),
              const SizedBox(height: AppSpacing.lg),

              const SectionLabel('When', icon: Icons.schedule),
              const SizedBox(height: AppSpacing.sm),
              _WhenRow(
                dateTime: _dateTime,
                onPickDate: _pickDate,
                onPickTime: _pickTime,
              ),
              const SizedBox(height: AppSpacing.lg),

              const SectionLabel('Notes', icon: Icons.notes_outlined),
              const SizedBox(height: AppSpacing.sm),
              _NotesField(controller: _notes),
              const SizedBox(height: AppSpacing.sm),
              // The cubit drops a write while another mutation is in flight or
              // before the initial load lands, so the buttons follow its own
              // guard instead of failing silently.
              BlocBuilder<SymptomsCubit, SymptomsState>(
                bloc: widget.cubit,
                builder: (context, state) {
                  final busy = _saving ||
                      state is! SymptomsLoaded ||
                      state.isLoading;
                  // SymptomsError also satisfies `state is! SymptomsLoaded`,
                  // so it folds into `busy` — but nothing can move the cubit
                  // out of it while this sheet covers the retry button, so
                  // "Just a moment…" would promise a resolution that cannot
                  // arrive. Name that dead end instead.
                  final hint = _type == null
                      ? 'Pick a symptom to continue'
                      : state is SymptomsError
                          ? 'Could not load your symptoms — close and try again'
                          : (busy ? 'Just a moment…' : null);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: _type == null || busy ? null : _save,
                        icon: const Icon(Icons.check),
                        label:
                            Text(isEditing ? 'Save changes' : 'Add symptom'),
                      ),
                      if (hint != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          hint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (isEditing) ...[
                        const SizedBox(height: AppSpacing.xs),
                        TextButton.icon(
                          onPressed: busy ? null : _delete,
                          icon: Icon(Icons.delete_outline,
                              color: theme.colorScheme.error),
                          label: Text(
                            'Delete',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final SymptomCategory category;
  final SymptomType? selected;
  final ValueChanged<SymptomType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final types =
        SymptomType.values.where((type) => categoryOf(type) == category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(symptomCategoryLabel(category), icon: _iconFor(category)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final type in types)
              ChoiceChip(
                label: Text(symptomTypeLabel(type)),
                selected: selected == type,
                onSelected: (isSelected) {
                  HapticFeedback.selectionClick();
                  onSelected(isSelected ? type : null);
                },
              ),
          ],
        ),
      ],
    );
  }

  static IconData _iconFor(SymptomCategory category) => switch (category) {
        SymptomCategory.pain => Icons.healing_outlined,
        SymptomCategory.mood => Icons.mood,
        SymptomCategory.physical => Icons.bolt_outlined,
        SymptomCategory.discharge => Icons.water_drop_outlined,
        SymptomCategory.other => Icons.spa_outlined,
      };
}

class _SeverityChips extends StatelessWidget {
  const _SeverityChips({required this.selected, required this.onSelected});

  final SymptomSeverity selected;
  final ValueChanged<SymptomSeverity> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final severity in SymptomSeverity.values)
          ChoiceChip(
            label: Text(symptomSeverityLabel(severity)),
            selected: selected == severity,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              onSelected(severity);
            },
          ),
      ],
    );
  }
}

class _WhenRow extends StatelessWidget {
  const _WhenRow({
    required this.dateTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  final DateTime dateTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);
    // An even split, not 3:2. The 3:2 version starved the time button: after
    // the theme's 20dp horizontal padding each side, the 18dp icon and its
    // 8dp gap, a 12-hour label like "10:30 PM" was left ~56dp on a 360dp
    // screen and soft-wrapped onto two lines beside a one-line date button.
    // Both labels carry the same overflow guard now, rather than only one.
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_today, size: AppIconSize.md),
            label: Text(
              materialLocalizations.formatMediumDate(dateTime),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickTime,
            icon: const Icon(Icons.access_time, size: AppIconSize.md),
            label: Text(
              TimeOfDay.fromDateTime(dateTime).format(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 3,
      maxLength: kSymptomNotesMaxLength,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        hintText: 'Anything worth remembering',
      ),
    );
  }
}
