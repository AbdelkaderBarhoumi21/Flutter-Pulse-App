extension StringX on String {
  /// True when the string is empty or only whitespace.
  bool get isBlank => trim().isEmpty;
}

extension NullableStringX on String? {
  /// True when the string is null, empty or only whitespace.
  bool get isNullOrBlank => this?.isBlank ?? true;
}
