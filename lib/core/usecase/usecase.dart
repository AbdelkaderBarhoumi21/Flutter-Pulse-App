import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';

/// Base class for all use cases
/// [Result] is the return type
/// [Params] is the input parameters type
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

class NoParams {
  const NoParams();
}
