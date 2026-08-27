import 'package:flutter/material.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Failed-load state for the symptom screens: an icon, copy the user can act
/// on (never the raw backend text — see [failureMessage]) and a way back in.
///
/// Every symptom screen owns its own [SymptomsCubit]/[SymptomPhaseCubit]
/// instance created in the route's [BlocProvider], so [onRetry] re-running the
/// load is the only recovery path short of leaving the screen.
class SymptomsErrorView extends StatelessWidget {
  const SymptomsErrorView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: AppIconSize.empty,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              failureMessage(AppLocalizations.of(context), failure),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).commonTryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
