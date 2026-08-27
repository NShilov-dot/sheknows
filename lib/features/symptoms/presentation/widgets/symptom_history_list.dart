import 'package:flutter/material.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';

/// Chronological list of symptom entries, grouped under a date header whenever
/// the day changes.
class SymptomHistoryList extends StatelessWidget {
  const SymptomHistoryList({
    super.key,
    required this.logs,
    required this.onTap,
  });

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
            if (showHeader) SymptomDateHeader(date: log.loggedAt),
            SymptomTile(log: log, onTap: () => onTap(log)),
          ],
        );
      },
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Day heading shown above the first entry logged on that date.
class SymptomDateHeader extends StatelessWidget {
  const SymptomDateHeader({super.key, required this.date});

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

/// A single symptom entry row: type, severity, time and optional notes.
class SymptomTile extends StatelessWidget {
  const SymptomTile({super.key, required this.log, required this.onTap});

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
