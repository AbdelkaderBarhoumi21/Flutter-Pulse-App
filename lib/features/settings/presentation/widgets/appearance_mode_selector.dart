import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/extensions/appearance_mode_extensions.dart';
import 'package:flutter_pulse_app/features/settings/domain/entities/appearance_mode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact icon-only System / Light / Dark switch for a settings row.
class AppearanceModeSelector extends StatelessWidget {
  const AppearanceModeSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final AppearanceMode selected;
  final ValueChanged<AppearanceMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AppearanceMode>(
      showSelectedIcon: false,
      segments: [
        for (final mode in AppearanceMode.values)
          ButtonSegment(
            value: mode,
            tooltip: mode.label,
            icon: Icon(mode.icon, size: AppIconSizes.sm.r),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.first),
    );
  }
}
