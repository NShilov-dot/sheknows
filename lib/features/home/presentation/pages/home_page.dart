import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_event.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('sheknows'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: BlocSelector<AuthBloc, AuthState, UserEntity?>(
        selector: (state) => state is AuthAuthenticated ? state.user : null,
        builder: (context, user) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return _AuthenticatedHome(user: user);
        },
      ),
    );
  }
}

class _AuthenticatedHome extends StatefulWidget {
  const _AuthenticatedHome({required this.user});

  final UserEntity user;

  @override
  State<_AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends State<_AuthenticatedHome> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Signed in',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text('Email: ${widget.user.email}'),
          const SizedBox(height: 8),
          Text(
            'Email confirmed: ${widget.user.emailConfirmed ? 'Yes' : 'No'}',
          ),
          const SizedBox(height: 24),
          Text(
            'Profile',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _ProfileSection(user: widget.user),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => context.go('/cycle'),
            icon: const Icon(Icons.calendar_month),
            label: const Text('Track my cycle'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.go('/symptoms'),
            icon: const Icon(Icons.healing_outlined),
            label: const Text('Log symptoms'),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _confirmDeleteAccount(context),
              icon: Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.error,
              ),
              label: Text(
                'Delete account',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account and all of your data. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
    }
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileCubit, ProfileState, _ProfileViewData>(
      selector: (state) => switch (state) {
        ProfileInitial() || ProfileLoading() => _ProfileViewData.loading,
        ProfileError(:final failure) => _ProfileViewData.error(failure.message),
        ProfileLoaded(:final profile) => _ProfileViewData.loaded(
            displayName: profile?.displayName ?? user.displayName,
            fromDatabase: profile != null,
          ),
      },
      builder: (context, data) {
        if (data.isLoading) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (data.errorMessage != null) {
          return Text(
            data.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${data.displayName ?? 'Not set'}'),
            const SizedBox(height: 4),
            Text(
              data.fromDatabase
                  ? 'Loaded from the profiles table.'
                  : 'No profile row found (showing auth metadata).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        );
      },
    );
  }
}

final class _ProfileViewData extends Equatable {
  const _ProfileViewData._({
    required this.isLoading,
    this.errorMessage,
    this.displayName,
    this.fromDatabase = false,
  });

  static const loading = _ProfileViewData._(isLoading: true);

  const _ProfileViewData.error(String message)
      : this._(isLoading: false, errorMessage: message);

  const _ProfileViewData.loaded({
    required String? displayName,
    required bool fromDatabase,
  }) : this._(
          isLoading: false,
          displayName: displayName,
          fromDatabase: fromDatabase,
        );

  final bool isLoading;
  final String? errorMessage;
  final String? displayName;
  final bool fromDatabase;

  @override
  List<Object?> get props => [isLoading, errorMessage, displayName, fromDatabase];
}
