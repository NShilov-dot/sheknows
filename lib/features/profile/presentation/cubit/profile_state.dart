import 'package:equatable/equatable.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/profile/domain/entities/profile_entity.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(
    this.profile, {
    this.isSaving = false,
    this.mutationFailure,
  });

  /// Null when the user has no profile row yet.
  final ProfileEntity? profile;

  /// True while an edit is in flight; [profile] already shows the new value.
  final bool isSaving;

  /// The last rejected edit, after [profile] has been rolled back.
  final Failure? mutationFailure;

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    bool? isSaving,
    Failure? mutationFailure,
    bool clearMutationFailure = false,
  }) {
    return ProfileLoaded(
      profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      mutationFailure: clearMutationFailure
          ? null
          : (mutationFailure ?? this.mutationFailure),
    );
  }

  @override
  List<Object?> get props => [profile, isSaving, mutationFailure];
}

final class ProfileError extends ProfileState {
  const ProfileError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
