import 'dart:ui';

import 'package:flutter_pulse_app/core/constants/app_layout.dart';

/// Picks the ScreenUtil design canvas for a screen: phone or tablet, flipped
/// in landscape so `.w`/`.h` keep sensible proportions after rotation.
abstract final class ResponsiveDesign {
  static Size designSizeFor(Size screen) {
    final isTablet = screen.shortestSide >= AppLayout.tabletBreakpoint;
    final base = isTablet
        ? AppLayout.tabletDesignSize
        : AppLayout.phoneDesignSize;
    final isLandscape = screen.width > screen.height;
    return isLandscape ? base.flipped : base;
  }
}
