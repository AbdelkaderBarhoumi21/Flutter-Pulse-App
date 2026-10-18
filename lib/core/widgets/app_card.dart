import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_radius.dart';
import 'package:flutter_pulse_app/core/constants/app_shadows.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/pressable_scale.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Rounded surface with a hairline border and a soft shadow. When [onTap]
/// is set it gets an ink ripple and press-to-shrink feedback.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding,
    this.gradient,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Defaults to [AppSpacing.md] on every side.
  final EdgeInsetsGeometry? padding;

  /// Replaces the surface colour and border (used for highlight cards).
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.lg.r);

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? colors.surface : null,
        gradient: gradient,
        borderRadius: radius,
        border: gradient == null ? Border.all(color: colors.border) : null,
        boxShadow: AppShadows.soft(colors.shadow),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.md.r),
            child: child,
          ),
        ),
      ),
    );

    return onTap == null ? card : PressableScale(child: card);
  }
}
