import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small uppercase caption above a group of content or a form field.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.xxs.w, bottom: AppSpacing.xs.h),
      child: Text(
        text.toUpperCase(),
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colors.textTertiary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
