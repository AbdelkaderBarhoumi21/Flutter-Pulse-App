import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';

/// Circular progress with a percentage in the middle. Animates whenever
/// [progress] changes.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    required this.size,
    required this.color,
    required this.trackColor,
    super.key,
  });

  /// `0..1`
  final double progress;
  final double size;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: progress.clamp(0, 1)),
      duration: AppDurations.slow,
      curve: AppCurves.emphasized,
      builder: (context, value, _) => SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: value,
              strokeWidth: size * 0.1,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: trackColor,
            ),
            Center(
              child: Text(
                '${(value * 100).round()}%',
                style: context.textTheme.titleSmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
