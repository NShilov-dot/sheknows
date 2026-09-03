import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/widgets/inline_error_row.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_trends.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/bar_row.dart';
import 'package:sheknows/core/widgets/skeleton_box.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The most-logged symptoms over the dashboard window as ranked bars, with a
/// way into the full trends screen.
class TopSymptomsCard extends StatelessWidget {
  const TopSymptomsCard({
    super.key,
    required this.trends,
    required this.failure,
    required this.windowDays,
    required this.onRetry,
  });

  /// Null while the logs are loading or after they failed to load.
  final SymptomTrends? trends;

  /// Set when the logs failed to load; shown inline with [onRetry].
  final Failure? failure;
  final int windowDays;
  final VoidCallback onRetry;

  static const _maxRows = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final trends = this.trends;
    final failure = this.failure;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.symptomTrendsMostFrequent,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.homeLastDays(windowDays),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (failure != null)
              InlineErrorRow(
                message: failureMessage(l10n, failure),
                onRetry: onRetry,
              )
            else if (trends == null)
              const _BarsSkeleton()
            else if (trends.isEmpty) ...[
              Text(
                l10n.symptomTrendsEmptyBody,
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/symptoms'),
                  icon: const Icon(Icons.add, size: AppIconSize.md),
                  label: Text(l10n.homeLogSymptomsButton),
                ),
              ),
            ] else ...[
              for (final entry in trends.byType.take(_maxRows))
                BarRow(
                  label: symptomTypeLabel(l10n, entry.type),
                  value: entry.count,
                  fraction: entry.count / trends.maxTypeCount,
                  color: theme.colorScheme.primary,
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.go('/symptom-trends'),
                  icon: const Icon(Icons.arrow_forward, size: AppIconSize.md),
                  label: Text(l10n.symptomTrendsTitle),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Three bar-shaped blocks with BarRow's own 10dp rhythm, so the card does not
/// change height when the real bars replace them.
class _BarsSkeleton extends StatelessWidget {
  const _BarsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < TopSymptomsCard._maxRows; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: SkeletonBox(height: 18),
          ),
      ],
    );
  }
}
