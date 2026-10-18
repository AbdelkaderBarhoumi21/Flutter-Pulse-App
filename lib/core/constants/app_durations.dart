/// Motion duration tokens. Pair them with [AppCurves].
abstract final class AppDurations {
  /// Micro-interactions: press feedback, toggles.
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard transitions: cross-fades, state changes.
  static const Duration medium = Duration(milliseconds: 280);

  /// Entrances and larger layout changes.
  static const Duration slow = Duration(milliseconds: 450);

  /// Delay between consecutive items of a staggered list entrance.
  static const Duration staggerStep = Duration(milliseconds: 45);
}
