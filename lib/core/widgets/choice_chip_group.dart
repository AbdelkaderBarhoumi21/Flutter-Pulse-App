import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_curves.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_radius.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/pressable_scale.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Single-select pill group for any value type — filters, priority, status,
/// theme mode. Selection changes animate colour and border.
class ChoiceChipGroup<T> extends StatelessWidget {
  const ChoiceChipGroup({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.labelOf,
    this.iconOf,
    this.colorOf,
    this.scrollable = false,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T option) labelOf;
  final IconData? Function(T option)? iconOf;

  /// Accent colour per option. Defaults to the primary colour.
  final Color Function(T option)? colorOf;

  /// One horizontally scrolling row instead of a wrapping layout.
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final option in options)
        _ChoicePill(
          label: labelOf(option),
          icon: iconOf?.call(option),
          color: colorOf?.call(option) ?? context.colorScheme.primary,
          selected: option == selected,
          onTap: () => onSelected(option),
        ),
    ];

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(spacing: AppSpacing.xs.w, children: chips),
      );
    }
    return Padding(
      padding: padding,
      child: Wrap(
        spacing: AppSpacing.xs.w,
        runSpacing: AppSpacing.xs.h,
        children: chips,
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? color : colors.textSecondary;
    final radius = BorderRadius.circular(AppRadius.pill);

    return Semantics(
      button: true,
      selected: selected,
      child: PressableScale(
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: AppCurves.standard,
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.13) : colors.surface,
            borderRadius: radius,
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.55) : colors.border,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md.w,
                  vertical: AppSpacing.xs.h + 1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppIconSizes.sm.r, color: foreground),
                      SizedBox(width: AppSpacing.xxs.w + 2),
                    ],
                    AnimatedDefaultTextStyle(
                      duration: AppDurations.medium,
                      style: context.textTheme.labelLarge!.copyWith(
                        color: foreground,
                      ),
                      child: Text(label),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
