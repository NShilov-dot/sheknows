import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_event.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_state.dart';
import 'package:sheknows/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:sheknows/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The account tab: who is signed in and their editable profile, then the
/// account actions — premium, sign-out — with deletion kept apart at the end.
///
/// Sign-out, delete-account and the name edit are all dispatched from here,
/// so this is where their failures surface.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _announce(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failureMessage(AppLocalizations.of(context), failure)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => current is AuthError,
          listener: (context, state) {
            if (state is AuthError) {
              _announce(context, state.failure);
              context.read<AuthBloc>().add(const AuthErrorCleared());
            }
          },
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              current is ProfileLoaded &&
              current.mutationFailure != null &&
              (previous is! ProfileLoaded ||
                  previous.mutationFailure != current.mutationFailure),
          listener: (context, state) {
            if (state is ProfileLoaded && state.mutationFailure != null) {
              _announce(context, state.mutationFailure!);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).profileTitle),
        ),
        body: BlocSelector<AuthBloc, AuthState, UserEntity?>(
          selector: (state) => state is AuthAuthenticated ? state.user : null,
          builder: (context, user) {
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return _ProfileView(user: user);
          },
        ),
      ),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView({required this.user});

  final UserEntity user;

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile(widget.user.id);
  }

  @override
  void didUpdateWidget(covariant _ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id) {
      context.read<ProfileCubit>().loadProfile(widget.user.id);
    }
  }

  Future<void> _openPaywall() async {
    // Same native-abort trap as RevenueCatIdentity: in dev mode configure()
    // never ran, so the paywall call would kill the app. No-op instead.
    if (!await Purchases.isConfigured) return;
    await RevenueCatUI.presentPaywallIfNeeded(
      'premium',
      displayCloseButton: true,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteAccountDialog(),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();
      context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final error = theme.colorScheme.error;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            ProfileHeaderCard(user: widget.user),
            const SizedBox(height: AppSpacing.xl),
            _SectionCaption(l10n.profileAccountSection),
            const SizedBox(height: AppSpacing.sm),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: Text(l10n.profileGoPremium),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _openPaywall,
                  ),
                  const Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(l10n.profileSignOut),
                    onTap: () => context
                        .read<AuthBloc>()
                        .add(const AuthSignOutRequested()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Its own card, at the end: a destructive row does not sit in the
            // same list as "sign out", one thumb-slip away.
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: error),
                title: Text(
                  l10n.profileDeleteAccount,
                  style: TextStyle(color: error),
                ),
                onTap: _confirmDeleteAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small muted heading above a card group.
class _SectionCaption extends StatelessWidget {
  const _SectionCaption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
