import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_radius.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_priority_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_status_extensions.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tinted pill for a task's status or priority. Colour and label animate
/// when the value changes.
class TaskBadge extends StatelessWidget {
  const TaskBadge.status(TaskStatus this.status, {super.key}) : priority = null;

  const TaskBadge.priority(TaskPriority this.priority, {super.key})
    : status = null;

  final TaskStatus? status;
  final TaskPriority? priority;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (label, icon, color) = switch ((status, priority)) {
      (final TaskStatus s, _) => (s.label, s.icon, s.colorOf(colors)),
      (_, final TaskPriority p) => (p.label, p.icon, p.colorOf(colors)),
      _ => throw StateError('TaskBadge needs a status or a priority'),
    };

    return AnimatedContainer(
      duration: AppDurations.medium,
      curve: AppCurves.standard,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: AnimatedSwitcher(
        duration: AppDurations.medium,
        child: Row(
          key: ValueKey(label),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppIconSizes.xs.r, color: color),
            SizedBox(width: AppSpacing.xxs.w),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
