import 'package:dartz/dartz.dart';
import 'package:supabase_flutter_starter_kit/core/error/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {
  const NoParams();
}
