import 'package:flutter/material.dart';
import 'package:sheknows/core/constants/symptoms.dart';
import 'package:sheknows/core/widgets/section_label.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
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
    if (type == null) {
      return;
    }
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
                isEditing ? 'Edit symptom' : 'Log a symptom',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              for (final category in SymptomCategory.values) ...[
                _CategoryChips(
                  category: category,
                  selected: _type,
                  onSelected: (type) => setState(() => _type = type),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 4),
              const SectionLabel('Severity', icon: Icons.thermostat),
              const SizedBox(height: 8),
              _SeverityChips(
                selected: _severity,
                onSelected: (severity) => setState(() => _severity = severity),
              ),
              const SizedBox(height: 16),

              const SectionLabel('When', icon: Icons.schedule),
              const SizedBox(height: 8),
              _WhenRow(
                dateTime: _dateTime,
                onPickDate: _pickDate,
                onPickTime: _pickTime,
              ),
              const SizedBox(height: 16),

              const SectionLabel('Notes', icon: Icons.notes_outlined),
              const SizedBox(height: 8),
              _NotesField(controller: _notes),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _type == null ? null : _save,
                icon: const Icon(Icons.check),
                label: Text(isEditing ? 'Save changes' : 'Add symptom'),
              ),
              if (isEditing) ...[
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _delete,
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final type in types)
              ChoiceChip(
                label: Text(symptomTypeLabel(type)),
                selected: selected == type,
                onSelected: (isSelected) =>
                    onSelected(isSelected ? type : null),
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
            onSelected: (_) => onSelected(severity),
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              materialLocalizations.formatMediumDate(dateTime),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickTime,
            icon: const Icon(Icons.access_time, size: 18),
            label: Text(
              TimeOfDay.fromDateTime(dateTime).format(context),
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
