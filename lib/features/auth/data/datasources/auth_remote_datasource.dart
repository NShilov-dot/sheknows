import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/config/environment.dart';
import 'package:sheknows/core/error/error_logger.dart';
import 'package:sheknows/core/error/exceptions.dart' as app_exceptions;
import 'package:sheknows/core/error/remote_call.dart';
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
      return user == null ? null : UserModel.fromSupabase(user);
    });
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) =>
      supabaseAuthCall(
        () async {
          final response = await _client.auth.signInWithPassword(
            email: email,
            password: password,
          );
          return _requireUser(response.user, 'Sign in failed');
        },
        'Sign in failed',
      );

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      supabaseAuthCall(
        () async {
          final response = await _client.auth.signUp(
            email: email,
            password: password,
          );
          return _requireUser(response.user, 'Sign up failed');
        },
        'Sign up failed',
      );

  @override
  Future<void> signInWithGoogle() => supabaseAuthCall(
        () async {
          final launched = await _client.auth.signInWithOAuth(
            OAuthProvider.google,
            redirectTo: Environment.oauthRedirectUrl,
            authScreenLaunchMode: LaunchMode.externalApplication,
          );
          if (!launched) {
            throw const app_exceptions.AuthException(
              'Could not open Google sign in',
            );
          }
        },
        'Google sign in failed',
      );

  @override
  Future<void> signOut() =>
      supabaseAuthCall(() => _client.auth.signOut(), 'Sign out failed');

  @override
  Future<void> deleteAccount() async {
    // The only call with a two-way map: the RPC raises PostgrestException,
    // the local sign-out that follows raises AuthException. Both are real and
    // mean different things to the user, so this one stays spelled out.
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
    } catch (error, stackTrace) {
      logError(error, stackTrace, context: 'Failed to delete account');
      throw const app_exceptions.ServerException('Failed to delete account');
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    return user == null ? null : UserModel.fromSupabase(user);
  }

  static UserModel _requireUser(User? user, String failureMessage) {
    if (user == null) {
      throw app_exceptions.AuthException(failureMessage);
    }
    return UserModel.fromSupabase(user);
  }
}
