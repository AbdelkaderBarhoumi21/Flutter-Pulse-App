import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_durations.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/pressable_scale.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AppButtonVariant {
  /// Filled with the primary colour — the main action of a screen.
  primary,

  /// Outlined — secondary actions.
  secondary,

  /// Soft error tint — destructive actions only.
  danger,
}

/// The app's button. Handles loading state (spinner, taps ignored) and
/// press feedback; disabled when [onPressed] is null.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;

  /// Stretch to the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    // While loading the button keeps its enabled look but ignores taps.
    final VoidCallback? handler = enabled
        ? (isLoading ? () {} : onPressed)
        : null;

    final content = AnimatedSwitcher(
      duration: AppDurations.fast,
      child: isLoading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: AppIconSizes.sm.r,
              // Built inside the button, so it picks up the variant's
              // foreground colour.
              child: Builder(
                builder: (context) => CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: IconTheme.of(context).color,
                ),
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppIconSizes.sm.r),
                  SizedBox(width: AppSpacing.xs.w),
                ],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: handler,
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: handler,
        child: content,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: handler,
        style: FilledButton.styleFrom(
          backgroundColor: context.colors.danger.withValues(alpha: 0.12),
          foregroundColor: context.colors.danger,
        ),
        child: content,
      ),
    };

    return PressableScale(
      enabled: enabled && !isLoading,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
