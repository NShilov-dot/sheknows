import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/error/guard.dart';
import 'package:sheknows/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sheknows/features/profile/domain/entities/profile_entity.dart';
import 'package:sheknows/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ProfileEntity?>> getProfile(String userId) =>
      guard(() => _remoteDataSource.getProfile(userId));
}
