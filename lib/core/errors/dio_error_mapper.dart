import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';

/// Translates [DioException]s into our [AppException] hierarchy so the
/// repository layer can map them to typed [Failure]s without knowing Dio.
class DioErrorMapper {
  const DioErrorMapper._();

  static AppException map(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return ServerException(
          'Server error: ${e.response?.statusCode ?? "Unknown status code"}',
        );

      case DioExceptionType.cancel:
        return const CancelledException();

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnexpectedException(e.message ?? 'Unexpected error occurred');
    }
  }
}
