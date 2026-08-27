import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_event.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/home/presentation/widgets/delete_account_dialog.dart';
import 'package:sheknows/features/home/presentation/widgets/profile_section.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failureMessage(l10n, state.failure))),
          );
          context.read<AuthBloc>().add(const AuthErrorCleared());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.homeAppBarTitle),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              icon: const Icon(Icons.logout),
              tooltip: l10n.homeSignOutTooltip,
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
  void didUpdateWidget(covariant _AuthenticatedHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id) {
      context.read<ProfileCubit>().loadProfile(widget.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const padding = EdgeInsets.all(AppSpacing.xl);

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - padding.vertical,
              ),
              child: IntrinsicHeight(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeSignedIn,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(l10n.homeEmailLabel(widget.user.email)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.user.emailConfirmed
                              ? l10n.homeEmailConfirmedYes
                              : l10n.homeEmailConfirmedNo,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.homeProfileSectionTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ProfileSection(user: widget.user),
                        const SizedBox(height: AppSpacing.xxl),
                        FilledButton.icon(
                          onPressed: () => context.go('/cycle'),
                          icon: const Icon(Icons.calendar_month),
                          label: Text(l10n.homeTrackCycleButton),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: () => context.go('/symptoms'),
                          icon: const Icon(Icons.healing_outlined),
                          label: Text(l10n.homeLogSymptomsButton),
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
                              l10n.homeDeleteAccountButton,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteAccountDialog(),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.heavyImpact();
      context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
    }
  }
}
