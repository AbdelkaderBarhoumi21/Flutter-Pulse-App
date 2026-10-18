import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/app_button.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom actions of the details screen: edit, and complete / reopen.
class TaskActionBar extends StatelessWidget {
  const TaskActionBar({
    required this.task,
    required this.isBusy,
    required this.onEdit,
    required this.onToggleCompleted,
    super.key,
  });

  final TaskEntity task;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: context.pagePadding.copyWith(
            top: AppSpacing.sm.h,
            bottom: AppSpacing.sm.h,
          ),
          child: Row(
            spacing: AppSpacing.sm.w,
            children: [
              Expanded(
                child: AppButton(
                  label: AppStrings.edit,
                  icon: Icons.edit_rounded,
                  variant: AppButtonVariant.secondary,
                  onPressed: isBusy ? null : onEdit,
                ),
              ),
              Expanded(
                child: AppButton(
                  label: task.isCompleted
                      ? AppStrings.reopen
                      : AppStrings.complete,
                  icon: task.isCompleted
                      ? Icons.replay_rounded
                      : Icons.check_rounded,
                  isLoading: isBusy,
                  onPressed: onToggleCompleted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
