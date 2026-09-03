import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  /// The user's profile row, or null when none exists yet.
  Future<Either<Failure, ProfileEntity?>> getProfile(String userId);

  /// Creates or updates the user's profile row with [displayName]; null
  /// clears the name. Returns the row as stored.
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String userId,
    required String? displayName,
  });
}
