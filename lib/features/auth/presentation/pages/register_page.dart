import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_event.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_state.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/utils/auth_validators.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/widgets/auth_page_scaffold.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthSignUpWithEmailRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _signInWithGoogle() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(const AuthSignInWithGoogleRequested());
  }

  void _onPasswordChanged(String _) {
    if (_confirmPasswordController.text.isNotEmpty) {
      _formKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthBloc, bool>(
      (bloc) => bloc.state is AuthLoading,
    );

    return AuthPageScaffold(
      title: 'Create account',
      subtitle: 'Sign up with email or Google',
      onUnauthenticatedMessage: (context, message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        context.go('/login');
      },
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
            const SizedBox(height: 16),
            AuthPasswordField(
              controller: _passwordController,
              label: 'Password',
              focusNode: _passwordFocusNode,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) =>
                  AuthValidators.password(value, forRegistration: true),
              onChanged: _onPasswordChanged,
              onFieldSubmitted: (_) => FocusScope.of(context)
                  .requestFocus(_confirmPasswordFocusNode),
            ),
            const SizedBox(height: 8),
            Text(
              'At least ${AuthValidators.minPasswordLength} characters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            AuthPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm password',
              focusNode: _confirmPasswordFocusNode,
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) => AuthValidators.confirmPassword(
                value,
                _passwordController.text,
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: 'Sign up',
              isLoading: isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            const AuthFormDivider(),
            const SizedBox(height: 16),
            AuthGoogleButton(
              isLoading: isLoading,
              onPressed: _signInWithGoogle,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: isLoading ? null : () => context.go('/login'),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
