import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_colors.dart';

/// Semantic colour tokens that Material's [ColorScheme] has no slot for.
///
/// Read them with `context.colors`. Each token has a light and a dark value,
/// so widgets never branch on brightness themselves.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.priorityLow,
    required this.priorityMedium,
    required this.priorityHigh,
    required this.shadow,
  });

  static const AppSemanticColors light = AppSemanticColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceMuted: AppColors.lightSurfaceMuted,
    border: AppColors.lightBorder,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    success: AppColors.green,
    warning: AppColors.amber,
    danger: AppColors.rose,
    info: AppColors.sky,
    priorityLow: AppColors.teal,
    priorityMedium: AppColors.amber,
    priorityHigh: AppColors.rose,
    shadow: Color(0x140F172A),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceMuted: AppColors.darkSurfaceMuted,
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    success: AppColors.greenLight,
    warning: AppColors.amberLight,
    danger: AppColors.roseLight,
    info: AppColors.skyLight,
    priorityLow: AppColors.tealLight,
    priorityMedium: AppColors.amberLight,
    priorityHigh: AppColors.roseLight,
    shadow: Color(0x66000000),
  );

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color priorityLow;
  final Color priorityMedium;
  final Color priorityHigh;
  final Color shadow;

  @override
  AppSemanticColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? priorityLow,
    Color? priorityMedium,
    Color? priorityHigh,
    Color? shadow,
  }) {
    return AppSemanticColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      priorityLow: priorityLow ?? this.priorityLow,
      priorityMedium: priorityMedium ?? this.priorityMedium,
      priorityHigh: priorityHigh ?? this.priorityHigh,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemanticColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      border: mix(border, other.border),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      danger: mix(danger, other.danger),
      info: mix(info, other.info),
      priorityLow: mix(priorityLow, other.priorityLow),
      priorityMedium: mix(priorityMedium, other.priorityMedium),
      priorityHigh: mix(priorityHigh, other.priorityHigh),
      shadow: mix(shadow, other.shadow),
    );
  }
}
