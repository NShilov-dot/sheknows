import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/config/environment.dart';
import 'package:sheknows/core/error/exceptions.dart' as app_exceptions;
import 'package:sheknows/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();

  Future<void> deleteAccount();

  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) {
        return null;
      }
      return UserModel.fromSupabase(user);
    });
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const app_exceptions.AuthException('Sign in failed');
      }
      return UserModel.fromSupabase(user);
    } on AuthException catch (error) {
      throw app_exceptions.AuthException(error.message);
    } catch (_) {
      throw const app_exceptions.AuthException('Sign in failed');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const app_exceptions.AuthException('Sign up failed');
      }
      return UserModel.fromSupabase(user);
    } on AuthException catch (error) {
      throw app_exceptions.AuthException(error.message);
    } catch (_) {
      throw const app_exceptions.AuthException('Sign up failed');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Environment.oauthRedirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const app_exceptions.AuthException('Could not open Google sign in');
      }
    } on AuthException catch (error) {
      throw app_exceptions.AuthException(error.message);
    } catch (_) {
      throw const app_exceptions.AuthException('Google sign in failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (error) {
      throw app_exceptions.AuthException(error.message);
    } catch (_) {
      throw const app_exceptions.AuthException('Sign out failed');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // Server-side security-definer RPC deletes the caller's own account
      // (see migration 20250619400000_delete_own_account.sql).
      await _client.rpc('delete_own_account');
      // The account is gone, so its token is dead server-side. Clear the
      // session locally (no network round-trip) to return to signed-out state.
      await _client.auth.signOut(scope: SignOutScope.local);
    } on PostgrestException catch (error) {
      throw app_exceptions.ServerException(error.message);
    } on AuthException catch (error) {
      throw app_exceptions.AuthException(error.message);
    } catch (_) {
      throw const app_exceptions.ServerException('Failed to delete account');
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    return UserModel.fromSupabase(user);
  }
}
