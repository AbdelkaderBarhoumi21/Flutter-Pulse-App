// [] optional POSITIONAL parameters
//{} optional NAMED parameters

/// Base exception class for all custom exceptions
/// implements = implement a contract/interface
abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

/// Thrown when server returns an error response
// extends = inherit (parent-child relationship)
class ServerException extends AppException {
  const ServerException([super.message = 'Server not occured']);
}

/// Thrown when there's no internet connection
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Thrown when validation fails
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}

/// Thrown when the user (or the app) cancelled an in-flight request.
/// Not a real error — the repository should not surface this to the UI.
class CancelledException extends AppException {
  const CancelledException([super.message = 'Request was cancelled']);
}

/// Thrown for anything we couldn't classify (e.g. DioExceptionType.unknown,
/// TLS / bad certificate failures). The repository maps this to UnexpectedFailure.
class UnexpectedException extends AppException {
  const UnexpectedException([super.message = 'Unexpected error occurred']);
}
