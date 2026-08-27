import 'package:sheknows/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sheknows/features/auth/data/models/user_model.dart';

/// DEV_MODE auth: a fixed signed-in user, no Supabase. Sign-in/up return the
/// same user; sign-out just ends the session so the login screen still works.
class DevAuthRemoteDataSource implements AuthRemoteDataSource {
  static const _user = UserModel(
    id: 'dev-user',
    email: 'dev@sheknows.local',
    displayName: 'Dev User',
    emailConfirmed: true,
  );

  @override
  Stream<UserModel?> get authStateChanges => Stream<UserModel?>.value(_user);

  @override
  UserModel? getCurrentUser() => _user;

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      _user;

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async =>
      _user;

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}
}
