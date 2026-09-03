import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/core/widgets/inline_error_row.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_state.dart';
import 'package:sheknows/features/profile/presentation/widgets/edit_display_name_sheet.dart';
import 'package:sheknows/core/widgets/skeleton_box.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Who is signed in: avatar, display name (or the invitation to add one),
/// email, and the way into the name editor.
///
/// The name and avatar prefer the `profiles` row and fall back to the auth
/// metadata a Google sign-in carries, which is also what the sign-up trigger
/// seeds the row from — so the two rarely disagree.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.user});

  final UserEntity user;

  static const _avatarSize = 56.0;

  void _openEditor(BuildContext context, String? currentName) {
    final cubit = context.read<ProfileCubit>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          EditDisplayNameSheet(cubit: cubit, initialName: currentName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final loaded = state is ProfileLoaded ? state : null;
        final name = loaded?.profile?.displayName ?? user.displayName;
        final avatarUrl = loaded?.profile?.avatarUrl ?? user.avatarUrl;
        final isLoading = state is ProfileInitial || state is ProfileLoading;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ProfileAvatar(
                      name: name,
                      email: user.email,
                      avatarUrl: avatarUrl,
                      size: _avatarSize,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: SkeletonBox(width: 140, height: 20),
                            )
                          else if (name != null)
                            Text(
                              name,
                              style: theme.textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Text(
                              l10n.profileAddName,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: muted),
                            ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            user.email,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Only once the row is known: editing over a load that may
                    // still bring a different name would race it.
                    if (loaded != null)
                      IconButton(
                        tooltip: l10n.profileEditName,
                        onPressed: loaded.isSaving
                            ? null
                            : () => _openEditor(context, name),
                        icon: loaded.isSaving
                            ? const SizedBox(
                                width: AppIconSize.md,
                                height: AppIconSize.md,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
                if (!user.emailConfirmed) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        Icons.mark_email_unread_outlined,
                        size: AppIconSize.sm,
                        color: muted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.profileEmailUnconfirmed,
                          style:
                              theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ),
                    ],
                  ),
                ],
                if (state is ProfileError) ...[
                  const SizedBox(height: AppSpacing.md),
                  InlineErrorRow(
                    message: failureMessage(l10n, state.failure),
                    onRetry: () =>
                        context.read<ProfileCubit>().loadProfile(user.id),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The user's picture, or their initials on the lavender container when
/// there is none (or it fails to load).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.size = 56,
  });

  final String? name;
  final String email;
  final String? avatarUrl;
  final double size;

  /// First letter of the first and last words of [name]; the email's first
  /// letter without one. Uppercased.
  static String initialsFor(String? name, String email) {
    final words = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return email.isEmpty ? '?' : email.substring(0, 1).toUpperCase();
    }
    final first = words.first.substring(0, 1);
    final last = words.length > 1 ? words.last.substring(0, 1) : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = avatarUrl;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: scheme.primaryContainer,
      foregroundImage: url == null ? null : NetworkImage(url),
      // A dead avatar URL falls through to the initials instead of an error.
      onForegroundImageError: url == null ? null : (_, __) {},
      child: Text(
        initialsFor(name, email),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
      ),
    );
  }
}
