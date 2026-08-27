import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_event.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';

class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    required this.title,
    required this.subtitle,
    required this.builder,
    this.onUnauthenticatedMessage,
    super.key,
  });

  final String title;
  final String subtitle;
  /// Builds the page body with the loading flag already derived from
  /// [AuthBloc] by this scaffold, so pages do not watch the bloc themselves.
  final Widget Function(BuildContext context, bool isLoading) builder;
  final void Function(BuildContext context, String message)? onUnauthenticatedMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              current is AuthError ||
              (current is AuthUnauthenticated && current.message != null),
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
              context.read<AuthBloc>().add(const AuthErrorCleared());
            }
            if (state is AuthUnauthenticated && state.message != null) {
              onUnauthenticatedMessage?.call(context, state.message!);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      IgnorePointer(
                        ignoring: isLoading,
                        child: Opacity(
                          opacity: isLoading ? 0.6 : 1,
                          child: builder(context, isLoading),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

