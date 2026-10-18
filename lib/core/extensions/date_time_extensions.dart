import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  /// Whether both instants fall on the same local calendar day.
  bool isSameDay(DateTime other) {
    final a = toLocal();
    final b = other.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Human friendly age: "Just now", "5 min ago", "Yesterday", "Oct 3, 2026".
  /// [now] is injectable for tests.
  String relativeLabel({DateTime? now}) {
    final reference = (now ?? DateTime.now()).toLocal();
    final local = toLocal();
    final diff = reference.difference(local);

    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inHours < 1) return AppStrings.minutesAgo(diff.inMinutes);
    if (local.isSameDay(reference)) return AppStrings.hoursAgo(diff.inHours);

    final days = _dateOnly(reference).difference(_dateOnly(local)).inDays;
    if (days == 1) return AppStrings.yesterday;
    if (days < 7) return AppStrings.daysAgo(days);
    return shortDate;
  }

  /// e.g. "Oct 18, 2026"
  String get shortDate => DateFormat.yMMMd().format(toLocal());

  /// e.g. "Sun, Oct 18, 2026 · 9:41 AM"
  String get fullDateTime =>
      '${DateFormat.yMMMEd().format(toLocal())} · '
      '${DateFormat.jm().format(toLocal())}';

  /// e.g. "Sunday, October 18"
  String get headline => DateFormat('EEEE, MMMM d').format(toLocal());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
