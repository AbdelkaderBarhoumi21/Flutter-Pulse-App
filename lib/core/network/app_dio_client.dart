import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/config/app_env.dart';
import 'package:flutter_pulse_app/core/utils/app_logger.dart';

/// Builds the configured [Dio]. The instance itself is owned by
/// `dioProvider`, and datasources receive it through their constructor.
abstract final class AppDioClient {
  static const Duration _timeout = Duration(seconds: 10);

  static Dio create({
    String baseUrl = AppEnv.apiBaseUrl,
    bool enableLogs = AppEnv.enableHttpLogs,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        contentType: Headers.jsonContentType,
        headers: {Headers.acceptHeader: Headers.jsonContentType},
      ),
    );
    if (enableLogs) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (line) => AppLogger.debug(line.toString()),
        ),
      );
    }
    return dio;
  }
}
