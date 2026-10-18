import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/animate_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Large page title with an optional eyebrow line above it, as a sliver.
class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, this.eyebrow, super.key});

  final String title;

  /// Small coloured line above the title (e.g. today's date).
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        context.pageGutter,
        AppSpacing.lg.h,
        context.pageGutter,
        AppSpacing.md.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null) ...[
              Text(
                eyebrow!.toUpperCase(),
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.primary,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: AppSpacing.xxs.h),
            ],
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineLarge,
            ),
          ],
        ).entrance(),
      ),
    );
  }
}
