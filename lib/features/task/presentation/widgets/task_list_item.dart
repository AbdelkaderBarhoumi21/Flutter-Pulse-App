import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_radius.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/utils/entrance_tracker.dart';
import 'package:flutter_pulse_app/core/widgets/entrance_once.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A task row of the list: entrance animation (once), swipe-to-delete and
/// the card itself.
class TaskListItem extends StatelessWidget {
  const TaskListItem({
    required this.task,
    required this.index,
    required this.entranceTracker,
    required this.onTap,
    required this.onToggleCompleted,
    required this.confirmDelete,
    required this.onDeleted,
    super.key,
  });

  final TaskEntity task;
  final int index;
  final EntranceTracker entranceTracker;
  final VoidCallback onTap;
  final VoidCallback onToggleCompleted;
  final Future<bool> Function() confirmDelete;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: EntranceOnce(
        id: task.id,
        index: index,
        tracker: entranceTracker,
        child: Dismissible(
          key: ValueKey('dismiss-${task.id}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => confirmDelete(),
          onDismissed: (_) => onDeleted(),
          background: const _DeleteBackground(),
          child: TaskCard(
            task: task,
            onTap: onTap,
            onToggleCompleted: onToggleCompleted,
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final danger = context.colors.danger;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: AppSpacing.xl.w),
          child: Icon(
            Icons.delete_outline_rounded,
            color: danger,
            size: AppIconSizes.lg.r,
          ),
        ),
      ),
    );
  }
}
