import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/network/app_api_endpoints.dart';

abstract class DeviceRemoteDataSource {
  Future<void> register({required String token, required String platform});
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio dio;
  DeviceRemoteDataSourceImpl(this.dio);

  @override
  Future<void> register({required String token, required String platform}) {
    return AppErrorGuard.guardThrowing(
      () => dio.post(
        AppApiEndpoints.registerDevice,
        data: {'token': token, 'platform': platform},
      ),
      parseErrorMessage: 'Failed to parse device registration response',
    );
  }
}
