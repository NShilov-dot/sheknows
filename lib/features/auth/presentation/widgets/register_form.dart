import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/features/auth/presentation/utils/auth_validators.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The email / password / confirm-password form of the register page.
///
/// The controllers, focus nodes and form key are owned by the page.
class RegisterForm extends StatelessWidget {
  const RegisterForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.confirmFieldKey,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.autovalidateMode,
    required this.isLoading,
    required this.onPasswordChanged,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormFieldState<String>> confirmFieldKey;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final AutovalidateMode autovalidateMode;
  final bool isLoading;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AutofillGroup(
      child: Form(
        key: formKey,
        autovalidateMode: autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: emailController,
              label: l10n.authEmailLabel,
              focusNode: emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                final error = AuthValidators.email(value);
                return error == null
                    ? null
                    : authValidationMessage(l10n, error);
              },
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(passwordFocusNode),
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthPasswordField(
              controller: passwordController,
              label: l10n.authPasswordLabel,
              focusNode: passwordFocusNode,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) {
                final error =
                    AuthValidators.password(value, forRegistration: true);
                return error == null
                    ? null
                    : authValidationMessage(l10n, error);
              },
              onChanged: onPasswordChanged,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(confirmPasswordFocusNode),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _PasswordRulesHint(),
            const SizedBox(height: AppSpacing.sm),
            AuthPasswordField(
              fieldKey: confirmFieldKey,
              controller: confirmPasswordController,
              label: l10n.authConfirmPasswordLabel,
              focusNode: confirmPasswordFocusNode,
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) {
                final error = AuthValidators.confirmPassword(
                  value,
                  passwordController.text,
                );
                return error == null
                    ? null
                    : authValidationMessage(l10n, error);
              },
              onFieldSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AuthPrimaryButton(
              label: l10n.authSignUp,
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordRulesHint extends StatelessWidget {
  const _PasswordRulesHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)
          .authPasswordRulesHint(AuthValidators.minPasswordLength),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
