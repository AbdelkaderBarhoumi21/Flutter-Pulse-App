import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/date_time_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 18, 15);

  group('relativeLabel', () {
    test('under a minute is "just now"', () {
      expect(
        now.subtract(const Duration(seconds: 30)).relativeLabel(now: now),
        AppStrings.justNow,
      );
    });

    test('future dates (clock skew) are "just now"', () {
      expect(
        now.add(const Duration(minutes: 5)).relativeLabel(now: now),
        AppStrings.justNow,
      );
    });

    test('minutes and hours on the same day', () {
      expect(
        now.subtract(const Duration(minutes: 5)).relativeLabel(now: now),
        AppStrings.minutesAgo(5),
      );
      expect(
        now.subtract(const Duration(hours: 3)).relativeLabel(now: now),
        AppStrings.hoursAgo(3),
      );
    });

    test('previous calendar day is "yesterday" even if < 24 h ago', () {
      final lateYesterday = DateTime(2026, 10, 17, 23);
      expect(lateYesterday.relativeLabel(now: now), AppStrings.yesterday);
    });

    test('within a week shows days, older shows a date', () {
      expect(
        DateTime(2026, 10, 14, 12).relativeLabel(now: now),
        AppStrings.daysAgo(4),
      );
      expect(DateTime(2026, 9, 2).relativeLabel(now: now), 'Sep 2, 2026');
    });
  });

  test('isSameDay compares local calendar days', () {
    expect(
      DateTime(2026, 10, 18, 1).isSameDay(DateTime(2026, 10, 18, 23)),
      isTrue,
    );
    expect(DateTime(2026, 10, 18).isSameDay(DateTime(2026, 10, 19)), isFalse);
  });

  test('formatters', () {
    final date = DateTime(2026, 10, 18, 9, 41);
    expect(date.shortDate, 'Oct 18, 2026');
    expect(date.headline, 'Sunday, October 18');
    // intl separates "AM" with a narrow no-break space (U+202F).
    expect(
      date.fullDateTime,
      matches(RegExp(r'^Sun, Oct 18, 2026 · 9:41\sAM$')),
    );
  });
}
