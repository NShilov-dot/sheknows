import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_event.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/home/presentation/widgets/delete_account_dialog.dart';
import 'package:sheknows/features/home/presentation/widgets/profile_section.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';

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
          ProfileSection(user: widget.user),
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
      builder: (_) => const DeleteAccountDialog(),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
    }
  }
}
