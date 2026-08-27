import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/theme/app_spacing.dart';

/// Shown by [GoRouter.errorBuilder] when a location matches no route — a stale
/// deep link, or a typo'd push. Replaces go_router's raw exception screen.
class RouteNotFoundPage extends StatelessWidget {
  const RouteNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore_off_outlined,
                    size: AppIconSize.empty,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: AppSpacing.md),
                Text('Page not found', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'That link does not lead anywhere.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Go home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
