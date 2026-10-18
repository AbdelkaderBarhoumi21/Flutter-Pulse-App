import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/animate_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/date_time_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/string_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/app_card.dart';
import 'package:flutter_pulse_app/core/widgets/app_list_tile.dart';
import 'package:flutter_pulse_app/core/widgets/section_label.dart';
import 'package:flutter_pulse_app/core/widgets/tile_group.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_entity.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_badge.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/task_priority_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Scrollable content of the details screen.
class TaskDetailsView extends StatelessWidget {
  const TaskDetailsView({required this.task, super.key});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final completedAt = task.completedAt;

    final sections = <Widget>[
      _Header(task: task),
      _Description(description: task.description),
      TileGroup(
        children: [
          AppListTile(
            icon: Icons.calendar_today_rounded,
            title: AppStrings.createdLabel,
            subtitle: task.createdAt.fullDateTime,
          ),
          AnimatedSize(
            duration: AppDurations.medium,
            curve: AppCurves.standard,
            child: completedAt == null
                ? const SizedBox(width: double.infinity)
                : AppListTile(
                    icon: Icons.event_available_rounded,
                    iconColor: context.colors.success,
                    title: AppStrings.completedLabel,
                    subtitle: completedAt.fullDateTime,
                  ),
          ),
        ],
      ),
    ];

    return ListView.separated(
      padding: context.pagePadding.copyWith(
        top: AppSpacing.xs.h,
        bottom: AppSpacing.xl.h,
      ),
      itemCount: sections.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md.h),
      itemBuilder: (_, index) => sections[index].entrance(index: index),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskPriorityIcon(task: task, iconSize: AppIconSizes.xl),
          SizedBox(height: AppSpacing.md.h),
          Text(task.title, style: context.textTheme.headlineSmall),
          SizedBox(height: AppSpacing.sm.h),
          Wrap(
            spacing: AppSpacing.xs.w,
            runSpacing: AppSpacing.xs.h,
            children: [
              TaskBadge.status(task.status),
              TaskBadge.priority(task.priority),
            ],
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final isEmpty = description.isBlank;
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(AppStrings.descriptionLabel),
          Text(
            isEmpty ? AppStrings.noDescription : description,
            style: isEmpty
                ? context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.textTertiary,
                    fontStyle: FontStyle.italic,
                  )
                : context.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
