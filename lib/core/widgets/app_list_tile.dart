import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_layout.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/icon_box.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact one-line row: icon, title, optional subtitle and trailing
/// control. Shows a chevron when tappable without a custom trailing.
class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final trailingWidget =
        trailing ??
        (onTap == null
            ? null
            : Icon(
                Icons.chevron_right_rounded,
                color: context.colors.textTertiary,
                size: AppIconSizes.md.r,
              ));

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: AppLayout.listTileMinHeight.h),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.xs.h,
          ),
          child: Row(
            children: [
              IconBox(icon: icon, color: iconColor, iconSize: AppIconSizes.sm),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (trailingWidget != null) ...[
                SizedBox(width: AppSpacing.xs.w),
                trailingWidget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
