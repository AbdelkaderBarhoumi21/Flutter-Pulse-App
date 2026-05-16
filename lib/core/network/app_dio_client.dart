import 'package:dio/dio.dart';


class AppDioClient {
  AppDioClient._();
  static final instance = AppDioClient._();
  Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'content-type': 'application/json'},
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  }
}
