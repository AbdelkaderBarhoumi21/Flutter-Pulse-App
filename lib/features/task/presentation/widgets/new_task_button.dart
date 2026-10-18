import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/widgets/pressable_scale.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Floating "New task" button that collapses to an icon while scrolling.
class NewTaskButton extends StatelessWidget {
  const NewTaskButton({
    required this.extended,
    required this.onPressed,
    super.key,
  });

  final bool extended;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: AppStrings.newTask,
        extendedPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
        extendedIconLabelSpacing: 0,
        icon: const Icon(Icons.add_rounded),
        label: AnimatedSize(
          duration: AppDurations.medium,
          curve: AppCurves.standard,
          child: extended
              ? Padding(
                  padding: EdgeInsets.only(left: AppSpacing.xs.w),
                  child: const Text(AppStrings.newTask),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
