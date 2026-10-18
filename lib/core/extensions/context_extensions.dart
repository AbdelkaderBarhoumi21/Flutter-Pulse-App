import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_layout.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/errors/failure_message.dart';
import 'package:flutter_pulse_app/core/theme/app_semantic_colors.dart';
import 'package:flutter_pulse_app/core/widgets/app_snack_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension AppContextX on BuildContext {
  // ── Theme ────────────────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  /// Semantic colour tokens (success, priority, borders, text levels…).
  AppSemanticColors get colors =>
      theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ── Layout ───────────────────────────────────────────────────────────────
  /// Horizontal page inset: the normal gutter on phones, and enough to cap
  /// content at [AppLayout.maxContentWidth] on wide screens.
  double get pageGutter {
    final width = MediaQuery.sizeOf(this).width;
    return math.max(AppSpacing.md.w, (width - AppLayout.maxContentWidth) / 2);
  }

  EdgeInsets get pagePadding => EdgeInsets.symmetric(horizontal: pageGutter);

  // ── Feedback ─────────────────────────────────────────────────────────────
  void showSnack(String message, {SnackTone tone = SnackTone.neutral}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(AppSnackBar.build(this, message: message, tone: tone));
  }

  /// Shows a friendly message for any failure/exception — never raw errors.
  void showError(Object error) =>
      showSnack(FailureMessage.of(error), tone: SnackTone.error);

  /// Placeholder feedback for buttons whose feature isn't built yet.
  void showComingSoon() => showSnack(AppStrings.comingSoon);

  void unfocus() => FocusScope.of(this).unfocus();
}
