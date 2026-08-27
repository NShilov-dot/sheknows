import 'package:flutter/material.dart';
import 'package:sheknows/features/auth/presentation/utils/auth_validators.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_text_field.dart';

/// The email / password / confirm-password form of the register page.
///
/// The controllers, focus nodes and form key are owned by the page.
class RegisterForm extends StatelessWidget {
  const RegisterForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
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
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final AutovalidateMode autovalidateMode;
  final bool isLoading;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: emailController,
            label: 'Email',
            focusNode: emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: AuthValidators.email,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(passwordFocusNode),
          ),
          const SizedBox(height: 16),
          AuthPasswordField(
            controller: passwordController,
            label: 'Password',
            focusNode: passwordFocusNode,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) =>
                AuthValidators.password(value, forRegistration: true),
            onChanged: onPasswordChanged,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(confirmPasswordFocusNode),
          ),
          const SizedBox(height: 8),
          const _PasswordRulesHint(),
          const SizedBox(height: 8),
          AuthPasswordField(
            controller: confirmPasswordController,
            label: 'Confirm password',
            focusNode: confirmPasswordFocusNode,
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) => AuthValidators.confirmPassword(
              value,
              passwordController.text,
            ),
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: 'Sign up',
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _PasswordRulesHint extends StatelessWidget {
  const _PasswordRulesHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'At least ${AuthValidators.minPasswordLength} characters, '
      'with a letter and a number',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
