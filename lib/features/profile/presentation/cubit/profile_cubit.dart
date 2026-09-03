import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/features/profile/domain/entities/profile_entity.dart';
import 'package:sheknows/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:sheknows/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetProfileUseCase getProfile,
    required UpdateProfileUseCase updateProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        super(const ProfileInitial());

  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;

  String? _cachedUserId;

  Future<void> loadProfile(String userId, {bool force = false}) async {
    if (!force && _cachedUserId == userId && state is ProfileLoaded) {
      return;
    }

    _cachedUserId = userId;
    emit(const ProfileLoading());
    final result = await _getProfile(GetProfileParams(userId));
    result.fold(
      (failure) => emit(ProfileError(failure)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  /// Saves [rawName] as the display name — trimmed, and cleared when blank.
  /// Optimistic: the header shows the new name at once and falls back to the
  /// old one, with the failure attached, if the write is rejected.
  Future<void> updateDisplayName(String? rawName) async {
    final userId = _cachedUserId;
    final snapshot = _loaded;
    if (userId == null || snapshot == null || snapshot.isSaving) {
      return;
    }
    final trimmed = rawName?.trim();
    final name = trimmed == null || trimmed.isEmpty ? null : trimmed;
    if (name == snapshot.profile?.displayName) {
      return;
    }

    emit(
      snapshot.copyWith(
        profile: ProfileEntity(
          id: userId,
          displayName: name,
          avatarUrl: snapshot.profile?.avatarUrl,
        ),
        isSaving: true,
        clearMutationFailure: true,
      ),
    );

    final result = await _updateProfile(
      UpdateProfileParams(userId: userId, displayName: name),
    );
    result.fold(
      (failure) => emit(snapshot.copyWith(mutationFailure: failure)),
      (saved) => emit(ProfileLoaded(saved)),
    );
  }

  void reset() {
    _cachedUserId = null;
    emit(const ProfileInitial());
  }

  ProfileLoaded? get _loaded {
    final state = this.state;
    return state is ProfileLoaded ? state : null;
  }
}
