import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/widgets/state_message_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders an [AsyncValue] with the app's standard states and cross-fades
/// between them: [loading] skeleton → [data], or a friendly error + retry.
///
/// Refreshes keep showing the current data instead of flashing the skeleton.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    required this.loading,
    this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.medium,
      child: value.when(
        data: (d) => KeyedSubtree(key: const ValueKey('data'), child: data(d)),
        loading: () =>
            KeyedSubtree(key: const ValueKey('loading'), child: loading),
        error: (error, _) => StateMessageView.error(
          key: const ValueKey('error'),
          error: error,
          onRetry: onRetry,
        ),
      ),
    );
  }
}
