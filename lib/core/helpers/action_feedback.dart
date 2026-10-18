import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/app_snack_bar.dart';

/// Turns the result of a user action into on-screen feedback, so screens
/// don't each repeat the same "await → mounted check → fold → snack" glue.
///
/// Feature-agnostic: it only knows `Either<Failure, T>`, never a feature.
abstract final class ActionFeedback {
  /// Awaits [action]. On failure shows a friendly error; on success shows
  /// [successMessage] (if given and non-null) as a success snack bar.
  /// Returns whether the action succeeded.
  static Future<bool> run<T>(
    BuildContext context,
    Future<Either<Failure, T>> action, {
    String? Function(T value)? successMessage,
  }) async {
    final result = await action;
    if (!context.mounted) return result.isRight();

    return result.fold(
      (failure) {
        context.showError(failure);
        return false;
      },
      (value) {
        final message = successMessage?.call(value);
        if (message != null) {
          context.showSnack(message, tone: SnackTone.success);
        }
        return true;
      },
    );
  }
}
