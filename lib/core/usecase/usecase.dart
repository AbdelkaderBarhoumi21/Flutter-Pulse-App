import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';

/// One business action. [Result] is the success type, [Params] the input.
abstract interface class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

class NoParams {
  const NoParams();
}
