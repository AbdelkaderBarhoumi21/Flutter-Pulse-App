import 'package:dartz/dartz.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/features/device/domain/repositories/device_repository.dart';
import 'package:flutter_pulse_app/features/device/domain/usecases/register_device_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late _MockDeviceRepository repository;
  late RegisterDeviceUseCase useCase;

  setUp(() {
    repository = _MockDeviceRepository();
    useCase = RegisterDeviceUseCase(repository);
    when(
      () => repository.registerDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer((_) async => const Right(unit));
  });

  test('rejects a blank token without calling the backend', () async {
    final result = await useCase.registerToken(token: ' ', platform: 'ios');
    expect(
      result,
      const Left<Failure, Unit>(
        ValidationFailure(AppStrings.deviceTokenRequired),
      ),
    );
    verifyNever(
      () => repository.registerDevice(
        token: any(named: 'token'),
        platform: any(named: 'platform'),
      ),
    );
  });

  test('works as the core PushTokenRegistrar port', () async {
    final result = await useCase.registerToken(token: 'abc', platform: 'ios');
    expect(result, const Right<Failure, Unit>(unit));
    verify(
      () => repository.registerDevice(token: 'abc', platform: 'ios'),
    ).called(1);
  });
}
