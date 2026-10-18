import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';

/// Maps any error to a friendly, user-facing sentence. Raw exception text
/// is never shown in the UI.
abstract final class FailureMessage {
  static String of(Object error) {
    return switch (error) {
      NetworkFailure() => AppStrings.errorNetwork,
      ServerFailure() => AppStrings.errorServer,
      ValidationFailure(:final message) => message,
      CancelledFailure() || UnexpectedFailure() => AppStrings.errorUnexpected,
      _ => AppStrings.errorUnexpected,
    };
  }
}
