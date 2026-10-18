import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_colors.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/pressable_scale.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Round checkbox that fills with the success colour when checked.
class TaskCheckButton extends StatelessWidget {
  const TaskCheckButton({
    required this.checked,
    required this.onPressed,
    super.key,
  });

  final bool checked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = AppIconSizes.lg.r;

    return Semantics(
      button: true,
      checked: checked,
      label: checked ? AppStrings.markIncomplete : AppStrings.markComplete,
      child: PressableScale(
        pressedScale: 0.85,
        child: InkResponse(
          onTap: onPressed,
          radius: size,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxs.r),
            child: AnimatedContainer(
              duration: AppDurations.medium,
              curve: AppCurves.standard,
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? colors.success : Colors.transparent,
                border: Border.all(
                  color: checked ? colors.success : colors.textTertiary,
                  width: 1.8,
                ),
              ),
              child: AnimatedSwitcher(
                duration: AppDurations.fast,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: checked
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('checked'),
                        size: AppIconSizes.sm.r,
                        color: AppColors.white,
                      )
                    : const SizedBox.shrink(key: ValueKey('unchecked')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
