import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/date_time_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/string_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/app_card.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_badge.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_check_button.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_priority_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onTap,
    required this.onToggleCompleted,
    super.key,
  });

  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleStyle = context.textTheme.titleMedium!;

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskPriorityIcon(task: task),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: AppDurations.medium,
                  style: task.isCompleted
                      ? titleStyle.copyWith(
                          color: colors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: colors.textTertiary,
                        )
                      : titleStyle,
                  child: Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!task.description.isBlank) ...[
                  SizedBox(height: AppSpacing.xxs.h),
                  Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium,
                  ),
                ],
                SizedBox(height: AppSpacing.sm.h),
                Row(
                  children: [
                    TaskBadge.status(task.status),
                    SizedBox(width: AppSpacing.xs.w),
                    Expanded(
                      child: Text(
                        task.createdAt.relativeLabel(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          TaskCheckButton(
            checked: task.isCompleted,
            onPressed: onToggleCompleted,
          ),
        ],
      ),
    );
  }
}
