/// Spacing scale in design pixels. Scale at the call site with `.w` / `.h`.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Extra bottom padding so list content clears the floating action button.
  static const double fabClearance = 96;
}
