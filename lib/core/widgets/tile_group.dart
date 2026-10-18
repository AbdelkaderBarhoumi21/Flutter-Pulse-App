import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_radius.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/widgets/app_card.dart';
import 'package:flutter_pulse_app/core/widgets/icon_box.dart';
import 'package:flutter_pulse_app/core/widgets/section_label.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A titled card that stacks rows (usually [AppListTile]s) with hairline
/// dividers between them.
class TileGroup extends StatelessWidget {
  const TileGroup({required this.children, this.title, super.key});

  final String? title;
  final List<Widget> children;

  /// Aligns dividers with the text of [AppListTile] rows, past the icon.
  static final double _dividerIndent =
      AppSpacing.md + IconBox.boxSizeFor(AppIconSizes.sm) + AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) SectionLabel(title!),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(indent: _dividerIndent.w),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
