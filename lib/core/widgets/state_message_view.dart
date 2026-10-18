import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_icon_sizes.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/errors/failure_message.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/extensions/animate_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/app_button.dart';
import 'package:flutter_pulse_app/core/widgets/icon_box.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centered icon + title + message (+ optional action). One widget for every
/// empty, error and "not found" state in the app.
class StateMessageView extends StatelessWidget {
  const StateMessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.isError = false,
    super.key,
  });

  /// Friendly error state with a retry button. Never shows raw errors.
  factory StateMessageView.error({
    required Object error,
    VoidCallback? onRetry,
    Key? key,
  }) {
    return StateMessageView(
      key: key,
      icon: error is NetworkFailure
          ? Icons.wifi_off_rounded
          : Icons.error_outline_rounded,
      title: AppStrings.errorTitle,
      message: FailureMessage.of(error),
      actionLabel: onRetry == null ? null : AppStrings.retry,
      actionIcon: Icons.refresh_rounded,
      onAction: onRetry,
      isError: true,
    );
  }

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl.w,
          vertical: AppSpacing.xl.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBox(
              icon: icon,
              iconSize: AppIconSizes.xl,
              color: isError ? context.colors.danger : null,
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.xl.h),
              AppButton(
                label: actionLabel!,
                icon: actionIcon,
                variant: AppButtonVariant.secondary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ).entrance(),
    );
  }
}
