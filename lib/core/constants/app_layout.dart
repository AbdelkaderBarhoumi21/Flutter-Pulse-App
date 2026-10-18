import 'package:flutter/painting.dart';

/// Layout tokens for responsive behaviour.
abstract final class AppLayout {
  /// Design canvas for phones (portrait). Flipped in landscape.
  static const Size phoneDesignSize = Size(390, 844);

  /// Design canvas for tablets (portrait), so UI isn't blown up on big screens.
  static const Size tabletDesignSize = Size(834, 1194);

  /// Shortest side (logical px) from which a device is treated as a tablet.
  static const double tabletBreakpoint = 600;

  /// Content never grows wider than this (logical px) on large screens.
  static const double maxContentWidth = 720;

  /// Only the first N list items get a staggered entrance delay.
  static const int maxStaggeredItems = 10;

  /// Component sizes in design pixels.
  static const double navigationBarHeight = 68;
  static const double listTileMinHeight = 60;
  static const double progressRingSize = 68;
}
