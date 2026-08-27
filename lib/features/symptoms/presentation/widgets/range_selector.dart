import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/symptoms/presentation/utils/analytics_range.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Chip row for picking the analytics window. Shared by the symptom trends and
/// cycle-phase screens, which previously carried byte-identical private copies.
class RangeSelector extends StatelessWidget {
  const RangeSelector({
    super.key,
    required this.range,
    required this.onChanged,
  });

  final AnalyticsRange range;
  final ValueChanged<AnalyticsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        for (final option in AnalyticsRange.values)
          ChoiceChip(
            label: Text(option.label(l10n)),
            selected: range == option,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              onChanged(option);
            },
          ),
      ],
    );
  }
}
