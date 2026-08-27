import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_event.dart';
import 'package:sheknows/features/auth/presentation/utils/auth_validators.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_alternative_actions.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext();
    context.read<AuthBloc>().add(
          AuthSignInWithEmailRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _signInWithGoogle() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(const AuthSignInWithGoogleRequested());
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue',
      builder: (context, isLoading) => AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: AuthValidators.email,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocusNode),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthPasswordField(
                controller: _passwordController,
                label: 'Password',
                focusNode: _passwordFocusNode,
                autofillHints: const [AutofillHints.password],
                validator: AuthValidators.password,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              AuthPrimaryButton(
                label: 'Sign in',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              AuthAlternativeActions(
                isLoading: isLoading,
                onGooglePressed: _signInWithGoogle,
                promptText: "Don't have an account?",
                actionLabel: 'Sign up',
                onActionPressed: () => context.go('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
