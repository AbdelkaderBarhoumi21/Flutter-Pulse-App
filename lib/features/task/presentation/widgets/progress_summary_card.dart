import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_colors.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_gradients.dart';
import 'package:flutter_pulse_app/core/constants/app_layout.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/task_status_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/app_card.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_stats.dart';
import 'package:flutter_pulse_app/features/task/domain/entities/task_status.dart';
import 'package:flutter_pulse_app/features/task/presentation/widgets/progress_ring.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Gradient highlight card: completion ring plus counts per status.
/// The gradient is the same in both themes, so its content is always white.
class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({required this.stats, super.key});

  final TaskStats stats;

  static const Color _foreground = AppColors.white;

  String get _headline {
    if (stats.total == 0) return AppStrings.progressEmpty;
    if (stats.completed == stats.total) return AppStrings.progressAllDone;
    return AppStrings.progressSummary(stats.completed, stats.total);
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;

    return AppCard(
      gradient: AppGradients.brand,
      padding: EdgeInsets.all(AppSpacing.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.progressTitle,
                      style: text.labelMedium?.copyWith(
                        color: _foreground.withValues(alpha: 0.75),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      _headline,
                      style: text.titleLarge?.copyWith(color: _foreground),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              ProgressRing(
                progress: stats.progress,
                size: AppLayout.progressRingSize.r,
                color: _foreground,
                trackColor: _foreground.withValues(alpha: 0.22),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg.h),
          Row(
            children: [
              for (final status in TaskStatus.values)
                Expanded(
                  child: _StatusCount(
                    label: status.label,
                    count: stats.countOf(status),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  const _StatusCount({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    const foreground = ProgressSummaryCard._foreground;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: AppDurations.medium,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            '$count',
            key: ValueKey(count),
            style: context.textTheme.headlineSmall?.copyWith(color: foreground),
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelMedium?.copyWith(
            color: foreground.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
