import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/extensions/string_extensions.dart';
import 'package:flutter_pulse_app/core/notifications/push_token_registrar.dart';
import 'package:flutter_pulse_app/core/usecase/usecase.dart';
import 'package:flutter_pulse_app/features/device/domain/repositories/device_repository.dart';

class RegisterDeviceParams {
  const RegisterDeviceParams({required this.token, required this.platform});
  final String token;
  final String platform;
}

/// Registers the device's push token. Also serves as the core
/// [PushTokenRegistrar] port, so the push layer can use it without
/// depending on this feature.
class RegisterDeviceUseCase
    implements UseCase<Unit, RegisterDeviceParams>, PushTokenRegistrar {
  const RegisterDeviceUseCase(this._repository);
  final DeviceRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(RegisterDeviceParams params) async {
    if (params.token.isBlank) {
      return const Left(ValidationFailure(AppStrings.deviceTokenRequired));
    }
    return _repository.registerDevice(
      token: params.token,
      platform: params.platform,
    );
  }

  @override
  Future<Either<Failure, Unit>> registerToken({
    required String token,
    required String platform,
  }) => call(RegisterDeviceParams(token: token, platform: platform));
}
