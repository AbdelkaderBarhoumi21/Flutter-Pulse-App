import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_priority.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_stats.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/progress_summary_card.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shimmering placeholder of the task list, built from the real widgets so
/// the layout doesn't jump when data arrives.
class TaskListSkeleton extends StatelessWidget {
  const TaskListSkeleton({super.key});

  static const int _placeholderCount = 5;

  static final TaskEntity _placeholder = TaskEntity(
    id: 'placeholder',
    title: 'Loading a task title here',
    description: 'A short description of the task goes here',
    priority: TaskPriority.medium,
    status: TaskStatus.pending,
    createdAt: DateTime(2026),
  );

  @override
  Widget build(BuildContext context) {
    // Placeholder cards contain Heroes; keep them out of route transitions.
    return HeroMode(
      enabled: false,
      child: Skeletonizer(
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            spacing: AppSpacing.sm.h,
            children: [
              const ProgressSummaryCard(
                stats: TaskStats(pending: 0, inProgress: 0, completed: 0),
              ),
              SizedBox(height: AppSpacing.xxl.h),
              for (var i = 0; i < _placeholderCount; i++)
                TaskCard(
                  task: _placeholder.copyWith(id: 'placeholder-$i'),
                  onTap: () {},
                  onToggleCompleted: () {},
                ),
            ],
          ),
        ),
      ),
    );
  }
}
