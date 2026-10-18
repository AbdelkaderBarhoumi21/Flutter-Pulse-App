import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/dio_error_mapper.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';

/// The two error-handling boundaries of the data layer.
///
/// * [guardThrowing] — used by **datasources**: anything that goes wrong is
///   re-thrown as a typed [AppException].
/// * [guardEither] — used by **repositories**: [AppException]s become the
///   matching [Failure] in a `Left`. Repositories never throw.
abstract final class AppErrorGuard {
  static Future<T> guardThrowing<T>(
    Future<T> Function() body, {
    String parseErrorMessage = 'Failed to parse response',
  }) async {
    try {
      return await body();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    } catch (e) {
      // Malformed payloads (bad casts, unknown enum values, bad dates…).
      throw UnexpectedException('$parseErrorMessage: $e');
    }
  }

  static Future<Either<Failure, T>> guardEither<T>(
    Future<T> Function() body,
  ) async {
    try {
      return Right(await body());
    } on AppException catch (e) {
      return Left(switch (e) {
        NetworkException() => NetworkFailure(e.message),
        ServerException() => ServerFailure(e.message),
        ValidationException() => ValidationFailure(e.message),
        CancelledException() => CancelledFailure(e.message),
        UnexpectedException() => UnexpectedFailure(e.message),
      });
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
