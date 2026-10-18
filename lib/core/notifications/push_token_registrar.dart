import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';

/// Port through which the push layer hands its device token to whoever
/// stores it (the `device` feature). Core depends on this abstraction, never
/// on the feature itself.
abstract interface class PushTokenRegistrar {
  Future<Either<Failure, Unit>> registerToken({
    required String token,
    required String platform,
  });
}
