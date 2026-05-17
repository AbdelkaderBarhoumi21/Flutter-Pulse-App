import 'package:dio/dio.dart';

/// Factory for building a configured [Dio] instance.
///
/// This class is a namespace — never instantiated. It builds the Dio;
/// the [Dio] itself is owned and shared by [dioProvider] in the DI layer,
/// so datasources receive it via constructor injection (testable + explicit).
class AppDioClient {
  const AppDioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'content-type': 'application/json'},
      ),
    );
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
    return dio;
  }
}
