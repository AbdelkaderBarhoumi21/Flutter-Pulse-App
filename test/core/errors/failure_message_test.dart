import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/errors/failure_message.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps failures to friendly messages, never raw text', () {
    expect(FailureMessage.of(const NetworkFailure()), AppStrings.errorNetwork);
    expect(
      FailureMessage.of(const ServerFailure('Server error: 500')),
      AppStrings.errorServer,
    );
    expect(
      FailureMessage.of(const UnexpectedFailure('type Null is not a subtype')),
      AppStrings.errorUnexpected,
    );
    expect(FailureMessage.of(Exception('boom')), AppStrings.errorUnexpected);
  });

  test('validation messages are already user-facing and pass through', () {
    expect(
      FailureMessage.of(const ValidationFailure(AppStrings.titleRequired)),
      AppStrings.titleRequired,
    );
  });
}
