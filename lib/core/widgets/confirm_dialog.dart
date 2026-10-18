import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/app_button.dart';
import 'package:flutter_pulse_app/core/widgets/icon_box.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Asks the user to confirm an action. Resolves to `true` only on confirm.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  IconData icon = Icons.help_outline_rounded,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      icon: icon,
      destructive: destructive,
    ),
  );
  return confirmed ?? false;
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.icon,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconBox(
                icon: icon,
                iconSize: AppIconSizes.lg,
                color: destructive ? context.colors.danger : null,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(title, style: context.textTheme.titleLarge),
            SizedBox(height: AppSpacing.xs.h),
            Text(message, style: context.textTheme.bodyMedium),
            SizedBox(height: AppSpacing.xl.h),
            Row(
              spacing: AppSpacing.sm.w,
              children: [
                Expanded(
                  child: AppButton(
                    label: AppStrings.cancel,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    variant: destructive
                        ? AppButtonVariant.danger
                        : AppButtonVariant.primary,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
