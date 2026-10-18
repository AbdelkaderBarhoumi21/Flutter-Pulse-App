import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/errors/app_error_guard.dart';
import 'package:flutter_pulse_app/core/errors/exceptions.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dio(DioExceptionType type, {int? status}) {
  final options = RequestOptions(path: '/tasks');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response<void>(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('guardThrowing', () {
    test('maps Dio errors to AppExceptions', () async {
      await expectLater(
        AppErrorGuard.guardThrowing<void>(
          () => throw _dio(DioExceptionType.connectionTimeout),
        ),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        AppErrorGuard.guardThrowing<void>(
          () => throw _dio(DioExceptionType.badResponse, status: 500),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('500'),
          ),
        ),
      );
      await expectLater(
        AppErrorGuard.guardThrowing<void>(
          () => throw _dio(DioExceptionType.cancel),
        ),
        throwsA(isA<CancelledException>()),
      );
    });

    // Regression: parse errors used to surface as a ValidationFailure whose
    // technical message was shown to users.
    test('malformed payloads become UnexpectedException', () async {
      await expectLater(
        AppErrorGuard.guardThrowing<int>(
          () async => (null as dynamic) as int,
          parseErrorMessage: 'Failed to parse',
        ),
        throwsA(isA<UnexpectedException>()),
      );
    });
  });

  group('guardEither', () {
    test('returns Right on success', () async {
      expect(
        await AppErrorGuard.guardEither(() async => 42),
        const Right<Failure, int>(42),
      );
    });

    test('maps each AppException to its Failure', () async {
      Future<Failure> failureFor(AppException e) async {
        final result = await AppErrorGuard.guardEither<void>(() => throw e);
        return result.fold((f) => f, (_) => fail('expected Left'));
      }

      expect(await failureFor(const NetworkException()), isA<NetworkFailure>());
      expect(await failureFor(const ServerException()), isA<ServerFailure>());
      expect(
        await failureFor(const ValidationException()),
        isA<ValidationFailure>(),
      );
      expect(
        await failureFor(const CancelledException()),
        isA<CancelledFailure>(),
      );
      expect(
        await failureFor(const UnexpectedException()),
        isA<UnexpectedFailure>(),
      );
    });

    test('unknown errors become UnexpectedFailure', () async {
      final result = await AppErrorGuard.guardEither<void>(
        () => throw StateError('x'),
      );
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<UnexpectedFailure>()), (_) {});
    });
  });
}
