import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_starter_kit/core/error/exceptions.dart' as app_exceptions;
import 'package:supabase_flutter_starter_kit/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      return ProfileModel.fromJson(row);
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to load profile');
    }
  }
}
