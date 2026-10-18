import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';

/// Translates [DioException]s into the [AppException] hierarchy so the rest
/// of the app never depends on Dio.
abstract final class DioErrorMapper {
  static AppException map(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => ServerException(
        'Server error: ${e.response?.statusCode ?? 'unknown status code'}',
      ),
      DioExceptionType.cancel => const CancelledException(),
      DioExceptionType.badCertificate || DioExceptionType.unknown =>
        UnexpectedException(e.message ?? 'Unexpected error occurred'),
    };
  }
}
