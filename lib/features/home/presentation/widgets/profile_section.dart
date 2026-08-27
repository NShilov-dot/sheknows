import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/features/auth/domain/entities/user_entity.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_state.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key, required this.user});

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
