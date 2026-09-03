import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/core/error/remote_call.dart';
import 'package:sheknows/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile(String userId);

  /// Inserts or updates the user's row, touching only `display_name`.
  Future<ProfileModel> upsertProfile({
    required String userId,
    required String? displayName,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<ProfileModel?> getProfile(String userId) => supabaseCall(
        () async {
          final row = await _client
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();
          return row == null ? null : ProfileModel.fromJson(row);
        },
        'Failed to load profile',
      );

  @override
  Future<ProfileModel> upsertProfile({
    required String userId,
    required String? displayName,
  }) =>
      supabaseCall(
        () async {
          // Upsert, not update: the sign-up trigger normally creates the row,
          // but the insert policy exists precisely for the case it did not.
          // Only the columns named here change; avatar_url is left alone.
          final row = await _client
              .from('profiles')
              .upsert({'id': userId, 'display_name': displayName})
              .select()
              .single();
          return ProfileModel.fromJson(row);
        },
        'Failed to save profile',
      );
}
