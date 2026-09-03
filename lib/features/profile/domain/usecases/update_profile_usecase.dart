import 'package:dartz/dartz.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/usecases/usecase.dart';
import 'package:sheknows/features/profile/domain/entities/profile_entity.dart';
import 'package:sheknows/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileParams {
  const UpdateProfileParams({required this.userId, required this.displayName});

  final String userId;

  /// Null clears the display name.
  final String? displayName;
}

class UpdateProfileUseCase
    implements UseCase<ProfileEntity, UpdateProfileParams> {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      userId: params.userId,
      displayName: params.displayName,
    );
  }
}
