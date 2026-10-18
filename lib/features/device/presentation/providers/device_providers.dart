import 'package:flutter_pulse_app/core/network/network_providers.dart';
import 'package:flutter_pulse_app/features/device/data/datasources/device_remote_datasource.dart';
import 'package:flutter_pulse_app/features/device/data/datasources/device_remote_datasource_impl.dart';
import 'package:flutter_pulse_app/features/device/data/repositories/device_repository_impl.dart';
import 'package:flutter_pulse_app/features/device/domain/repositories/device_repository.dart';
import 'package:flutter_pulse_app/features/device/domain/usecases/register_device_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>(
  (ref) => DeviceRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepositoryImpl(ref.watch(deviceRemoteDataSourceProvider)),
);

final registerDeviceUseCaseProvider = Provider<RegisterDeviceUseCase>(
  (ref) => RegisterDeviceUseCase(ref.watch(deviceRepositoryProvider)),
);
