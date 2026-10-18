import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/features/device/data/datasources/device_remote_datasource.dart';
import 'package:flutter_pulse_app/features/device/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  const DeviceRepositoryImpl(this._remote);
  final DeviceRemoteDataSource _remote;

  @override
  Future<Either<Failure, Unit>> registerDevice({
    required String token,
    required String platform,
  }) {
    return AppErrorGuard.guardEither(() async {
      await _remote.register(token: token, platform: platform);
      return unit;
    });
  }
}
