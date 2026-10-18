import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Elevation tokens. Colours come from the theme (`context.colors.shadow`).
abstract final class AppShadows {
  /// Soft, low-contrast shadow under cards.
  static List<BoxShadow> soft(Color color) => [
    BoxShadow(
      color: color,
      blurRadius: 24.r,
      spreadRadius: -12.r,
      offset: Offset(0, 10.h),
    ),
  ];
}
