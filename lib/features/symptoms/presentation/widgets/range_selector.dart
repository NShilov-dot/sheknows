import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/symptoms/presentation/utils/analytics_range.dart';

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
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final option in AnalyticsRange.values)
          ChoiceChip(
            label: Text(option.label),
            selected: range == option,
            onSelected: (_) => onChanged(option),
          ),
      ],
    );
  }
}
