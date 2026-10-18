import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_radius.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// An icon on a soft tinted rounded square — the app's consistent icon style.
/// Defaults to the primary colour.
class IconBox extends StatelessWidget {
  const IconBox({
    required this.icon,
    this.color,
    this.iconSize = AppIconSizes.md,
    super.key,
  });

  final IconData icon;
  final Color? color;

  /// Design-pixel size of the glyph; the box is proportionally larger.
  final double iconSize;

  /// Side length (design px) of the box drawn around an [iconSize] glyph.
  static double boxSizeFor(double iconSize) => iconSize * 1.85;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.colorScheme.primary;
    return AnimatedContainer(
      duration: AppDurations.medium,
      curve: AppCurves.standard,
      width: boxSizeFor(iconSize).r,
      height: boxSizeFor(iconSize).r,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(
          (iconSize >= AppIconSizes.xl ? AppRadius.lg : AppRadius.sm).r,
        ),
      ),
      child: Icon(icon, color: tint, size: iconSize.r),
    );
  }
}
