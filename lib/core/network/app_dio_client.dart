import 'package:dio/dio.dart';

class AppDioClient {
  AppDioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'content-type': 'application/json'},
    ),
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
}
