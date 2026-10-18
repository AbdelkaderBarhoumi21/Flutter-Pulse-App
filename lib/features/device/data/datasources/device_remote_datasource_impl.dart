import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/network/app_api_endpoints.dart';
import 'package:flutter_pulse_app/features/device/data/datasources/device_remote_datasource.dart';

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  const DeviceRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<void> register({required String token, required String platform}) {
    return AppErrorGuard.guardThrowing(
      () => _dio.post<void>(
        AppApiEndpoints.devices,
        data: {'token': token, 'platform': platform},
      ),
      parseErrorMessage: 'Failed to parse device registration response',
    );
  }
}
