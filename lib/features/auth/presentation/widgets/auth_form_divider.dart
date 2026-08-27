import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class AuthFormDivider extends StatelessWidget {
  const AuthFormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            AppLocalizations.of(context).authDividerOr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
