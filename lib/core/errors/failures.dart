import 'package:equatable/equatable.dart';

/// Typed errors returned by repositories and use cases as `Left(Failure)`.
///
/// `sealed` so a `switch` over failures is checked for exhaustiveness.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Technical description for logs. Users see `FailureMessage.of(failure)`.
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// A business rule was violated. Its [message] is user-facing.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Request was cancelled']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error occurred']);
}
