import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: const Icon(Icons.g_mobiledata, size: AppIconSize.lg),
      label: Text(AppLocalizations.of(context).authContinueWithGoogle),
    );
  }
}
