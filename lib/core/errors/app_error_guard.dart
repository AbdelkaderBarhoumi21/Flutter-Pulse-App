import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/dio_error_mapper.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';

/// Utility (namespace) class — never instantiated.
/// Centralizes the two error-handling boundaries in the app:
/// There's no object anywhere. AppErrorGuard is just a label that groups two functions.
/// Dart never allocates anything called "an AppErrorGuard."
/// * [guardThrowing] — used by **datasources**. Runs [body] and re-throws
///   any failure as a typed [AppException] (so the repository can map it).
///
/// * [guardEither] — used by **repositories**. Runs [body] and converts any
///   thrown [AppException] into the matching [Failure], returned as
///   `Either<Failure, T>`. Repositories never throw — they return.
class AppErrorGuard {
  const AppErrorGuard._();

  /// Datasource-side guard. Returns `T` on success, throws [AppException] on
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
    } catch (_) {
      throw ValidationException(parseErrorMessage);
    }
  }

  /// Repository-side guard. Returns `Right(T)` on success and `Left(Failure)`
  static Future<Either<Failure, T>> guardEither<T>(
    Future<T> Function() body,
  ) async {
    try {
      final result = await body();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on CancelledException catch (e) {
      return Left(CancelledFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnexpectedFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
