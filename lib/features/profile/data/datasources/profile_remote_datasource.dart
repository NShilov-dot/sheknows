import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/core/error/remote_call.dart';
import 'package:sheknows/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile(String userId);
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
}
