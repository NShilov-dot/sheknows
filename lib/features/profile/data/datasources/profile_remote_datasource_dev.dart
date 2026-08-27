import 'package:sheknows/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sheknows/features/profile/data/models/profile_model.dart';

/// DEV_MODE profile: no row, so home falls back to auth metadata.
class DevProfileRemoteDataSource implements ProfileRemoteDataSource {
  @override
  Future<ProfileModel?> getProfile(String userId) async => null;
}
