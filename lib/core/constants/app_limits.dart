/// Business limits shared by validation and the UI (counters, max lengths).
abstract final class AppLimits {
  static const int minTitleLength = 3;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
}
