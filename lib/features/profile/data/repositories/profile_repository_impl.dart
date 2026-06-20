import 'package:dartz/dartz.dart';
import 'package:supabase_flutter_starter_kit/core/error/exceptions.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:supabase_flutter_starter_kit/features/profile/domain/entities/profile_entity.dart';
import 'package:supabase_flutter_starter_kit/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ProfileEntity?>> getProfile(String userId) async {
    try {
      final profile = await _remoteDataSource.getProfile(userId);
      return Right(profile);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
