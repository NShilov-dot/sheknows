import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The app that runs when start-up failed. It owns its own [MaterialApp]
/// because DI, Supabase and the local store may all be unavailable at this
/// point — nothing here depends on anything `main()` was trying to build.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sheknows',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: AppIconSize.empty,
                          color: theme.colorScheme.error),
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.commonStartupFailureTitle,
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.commonStartupFailureBody,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppRadius.field),
                        ),
                        child: Text(
                          '$error',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontFamilyFallback: const ['Courier'],
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
