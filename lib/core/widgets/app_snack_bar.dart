import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SnackTone { neutral, success, error }

/// Builds the app's floating snack bar. Show it via `context.showSnack`.
abstract final class AppSnackBar {
  static SnackBar build(
    BuildContext context, {
    required String message,
    SnackTone tone = SnackTone.neutral,
  }) {
    final colors = context.colors;
    final (icon, iconColor) = switch (tone) {
      SnackTone.neutral => (null, null),
      SnackTone.success => (Icons.check_circle_rounded, colors.success),
      SnackTone.error => (Icons.error_rounded, colors.danger),
    };

    return SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: AppIconSizes.md.r),
            SizedBox(width: AppSpacing.sm.w),
          ],
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
