/// Exceptions thrown by datasources. Repositories turn them into [Failure]s
/// (see `AppErrorGuard.guardEither`), so they never reach the UI.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The server answered with an error status code.
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

/// No connection, or the request timed out.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Input rejected by business rules.
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}

/// The request was cancelled. Not a real error — don't surface it to users.
class CancelledException extends AppException {
  const CancelledException([super.message = 'Request was cancelled']);
}

/// Anything we couldn't classify: malformed payloads, TLS failures, etc.
class UnexpectedException extends AppException {
  const UnexpectedException([super.message = 'Unexpected error occurred']);
}
