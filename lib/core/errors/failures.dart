import 'package:equatable/equatable.dart';

/// Base failure class for all errors
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

/// Failure when server returns an error
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Failure when there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error occurred']);
}

/// Failure when the user (or the app) cancelled an in-flight request.
/// Not a user-facing error — the ViewModel should usually ignore it.
class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Request was cancelled']);
}
