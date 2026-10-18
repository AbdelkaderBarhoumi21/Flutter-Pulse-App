import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';

abstract interface class DeviceRepository {
  Future<Either<Failure, Unit>> registerDevice({
    required String token,
    required String platform,
  });
}
