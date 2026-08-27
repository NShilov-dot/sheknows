import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_form_divider.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_google_button.dart';

/// The divider, Google sign-in button and "switch page" footer prompt shared by
/// the login and register pages.
class AuthAlternativeActions extends StatelessWidget {
  const AuthAlternativeActions({
    required this.isLoading,
    required this.onGooglePressed,
    required this.promptText,
    required this.actionLabel,
    required this.onActionPressed,
    super.key,
  });

  final bool isLoading;
  final VoidCallback onGooglePressed;
  final String promptText;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const AuthFormDivider(),
        const SizedBox(height: AppSpacing.lg),
        AuthGoogleButton(
          isLoading: isLoading,
          onPressed: onGooglePressed,
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(promptText),
            TextButton(
              onPressed: isLoading ? null : onActionPressed,
              child: Text(actionLabel),
            ),
          ],
        ),
      ],
    );
  }
}
