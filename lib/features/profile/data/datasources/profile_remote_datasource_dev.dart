import 'package:sheknows/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sheknows/features/profile/data/models/profile_model.dart';

/// DEV_MODE profile store: in-memory, no Supabase. Starts without a row, so
/// the header falls back to the auth metadata name until one is saved; data
/// resets on every app restart.
class DevProfileRemoteDataSource implements ProfileRemoteDataSource {
  ProfileModel? _profile;

  @override
  Future<ProfileModel?> getProfile(String userId) async => _profile;

  @override
  Future<ProfileModel> upsertProfile({
    required String userId,
    required String? displayName,
  }) async {
    return _profile = ProfileModel(
      id: userId,
      displayName: displayName,
      avatarUrl: _profile?.avatarUrl,
    );
  }
}
