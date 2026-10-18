import 'package:flutter/animation.dart';

/// Motion curve tokens. Everything eases out so motion feels responsive.
abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
}
