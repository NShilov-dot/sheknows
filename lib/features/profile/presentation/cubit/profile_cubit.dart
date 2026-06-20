import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_starter_kit/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:supabase_flutter_starter_kit/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required GetProfileUseCase getProfile})
      : _getProfile = getProfile,
        super(const ProfileInitial());

  final GetProfileUseCase _getProfile;

  String? _cachedUserId;

  Future<void> loadProfile(String userId, {bool force = false}) async {
    if (!force &&
        _cachedUserId == userId &&
        state is ProfileLoaded) {
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

  void reset() {
    _cachedUserId = null;
    emit(const ProfileInitial());
  }
}
