import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';

/// An icon + title heading used to introduce a section inside a bottom sheet.
///
/// Shared by the period day-details sheet and the symptom log sheet, which
/// previously carried byte-identical private copies.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {required this.icon, super.key});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSize.md,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.titleSmall),
      ],
    );
  }
}
