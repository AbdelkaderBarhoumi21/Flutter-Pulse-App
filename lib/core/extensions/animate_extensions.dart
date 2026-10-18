import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_layout.dart';

extension AppAnimateX on Widget {
  /// Subtle fade + slide-up entrance. Only the first
  /// [AppLayout.maxStaggeredItems] items get a staggered delay, so long lists
  /// never feel slow.
  Widget entrance({int index = 0}) {
    final delay = index < AppLayout.maxStaggeredItems
        ? AppDurations.staggerStep * index
        : Duration.zero;
    return animate(delay: delay)
        .fadeIn(duration: AppDurations.slow, curve: AppCurves.standard)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: AppDurations.slow,
          curve: AppCurves.emphasized,
        );
  }
}
