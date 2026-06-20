import 'package:dartz/dartz.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';
import 'package:supabase_flutter_starter_kit/core/usecases/usecase.dart';
import 'package:supabase_flutter_starter_kit/features/profile/domain/entities/profile_entity.dart';
import 'package:supabase_flutter_starter_kit/features/profile/domain/repositories/profile_repository.dart';

class GetProfileParams {
  const GetProfileParams(this.userId);

  final String userId;
}

class GetProfileUseCase implements UseCase<ProfileEntity?, GetProfileParams> {
  GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, ProfileEntity?>> call(GetProfileParams params) {
    return _repository.getProfile(params.userId);
  }
}
