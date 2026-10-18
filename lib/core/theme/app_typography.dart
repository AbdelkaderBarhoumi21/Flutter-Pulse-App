import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The single type scale of the app (Plus Jakarta Sans, bundled as assets).
abstract final class AppTypography {
  static const String fontFamily = 'PlusJakartaSans';

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    TextStyle style(
      double size,
      FontWeight weight, {
      double height = 1.35,
      double letterSpacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size.sp,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color ?? primary,
      );
    }

    return TextTheme(
      displaySmall: style(34, FontWeight.w800, height: 1.15, letterSpacing: -1),
      headlineLarge: style(
        30,
        FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.8,
      ),
      headlineMedium: style(
        26,
        FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      headlineSmall: style(
        22,
        FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      titleLarge: style(19, FontWeight.w700, letterSpacing: -0.2),
      titleMedium: style(16, FontWeight.w600),
      titleSmall: style(14, FontWeight.w600),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(14, FontWeight.w400, height: 1.45, color: secondary),
      bodySmall: style(12.5, FontWeight.w400, color: secondary),
      labelLarge: style(14, FontWeight.w600, letterSpacing: 0.1),
      labelMedium: style(12.5, FontWeight.w600, letterSpacing: 0.1),
      labelSmall: style(11, FontWeight.w600, letterSpacing: 0.3),
    );
  }
}
