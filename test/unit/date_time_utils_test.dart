import 'package:flutter_test/flutter_test.dart';
import 'package:plant_dd_ai/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils.fromUnixTimestamp', () {
    test('converts unix timestamp (seconds) to DateTime correctly', () {
      // 2024-01-15 00:00:00 UTC → 1705276800
      final dt = DateTimeUtils.fromUnixTimestamp(1705276800);
      expect(dt.year, equals(2024));
      expect(dt.month, equals(1));
      expect(dt.day, equals(15));
    });

    test('handles timestamp 0 as epoch', () {
      final dt = DateTimeUtils.fromUnixTimestamp(0);
      expect(dt.millisecondsSinceEpoch, equals(0));
    });
  });

  // ---------------------------------------------------------------------------
  group('DateTimeUtils.toUnixTimestamp', () {
    test('round-trips correctly through fromUnixTimestamp', () {
      final original = DateTime(2025, 6, 20, 12, 0, 0);
      final ts = DateTimeUtils.toUnixTimestamp(original);
      final restored = DateTimeUtils.fromUnixTimestamp(ts);
      // Only seconds precision — compare to second
      expect(restored.year, equals(original.year));
      expect(restored.month, equals(original.month));
      expect(restored.day, equals(original.day));
      expect(restored.hour, equals(original.hour));
      expect(restored.minute, equals(original.minute));
      expect(restored.second, equals(original.second));
    });

    test('uses integer division — truncates milliseconds', () {
      final dt = DateTime.fromMillisecondsSinceEpoch(1705276800500); // +500ms
      final ts = DateTimeUtils.toUnixTimestamp(dt);
      expect(ts, equals(1705276800)); // milliseconds stripped
    });
  });

  // ---------------------------------------------------------------------------
  group('DateTimeUtils.formatDate', () {
    test('formats date as "MMM d, y"', () {
      final dt = DateTime(2024, 3, 5);
      expect(DateTimeUtils.formatDate(dt), equals('Mar 5, 2024'));
    });

    test('formats single-digit days without leading zero', () {
      final dt = DateTime(2024, 11, 1);
      expect(DateTimeUtils.formatDate(dt), equals('Nov 1, 2024'));
    });
  });

  // ---------------------------------------------------------------------------
  group('DateTimeUtils.formatDateTime', () {
    test('includes time component in output', () {
      final dt = DateTime(2024, 3, 5, 14, 30);
      final formatted = DateTimeUtils.formatDateTime(dt);
      // Should contain "Mar 5, 2024" and a time part
      expect(formatted, contains('Mar 5, 2024'));
      expect(formatted, contains('30')); // minute
    });
  });

  // ---------------------------------------------------------------------------
  group('DateTimeUtils.formatRelativeTime', () {
    test('returns "Just now" for very recent timestamps', () {
      final now = DateTime.now().subtract(const Duration(seconds: 10));
      expect(DateTimeUtils.formatRelativeTime(now), equals('Just now'));
    });

    test('returns minutes ago for timestamps within the last hour', () {
      final recent = DateTime.now().subtract(const Duration(minutes: 45));
      final result = DateTimeUtils.formatRelativeTime(recent);
      expect(result, contains('minute'));
      expect(result, contains('45'));
    });

    test('uses singular "minute" for exactly 1 minute ago', () {
      final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
      final result = DateTimeUtils.formatRelativeTime(oneMinuteAgo);
      expect(result, equals('1 minute ago'));
    });

    test('returns hours ago for timestamps within the last day', () {
      final hoursAgo = DateTime.now().subtract(const Duration(hours: 3));
      final result = DateTimeUtils.formatRelativeTime(hoursAgo);
      expect(result, contains('hour'));
    });

    test('uses singular "hour" for exactly 1 hour ago', () {
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
      final result = DateTimeUtils.formatRelativeTime(oneHourAgo);
      expect(result, equals('1 hour ago'));
    });

    test('returns days ago for timestamps within the last month', () {
      final daysAgo = DateTime.now().subtract(const Duration(days: 5));
      final result = DateTimeUtils.formatRelativeTime(daysAgo);
      expect(result, equals('5 days ago'));
    });

    test('uses singular "day" for exactly 1 day ago', () {
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
      final result = DateTimeUtils.formatRelativeTime(oneDayAgo);
      expect(result, equals('1 day ago'));
    });

    test('returns months ago for timestamps within the last year', () {
      final monthsAgo = DateTime.now().subtract(const Duration(days: 65));
      final result = DateTimeUtils.formatRelativeTime(monthsAgo);
      expect(result, contains('month'));
    });

    test('returns years ago for timestamps older than a year', () {
      final yearsAgo = DateTime.now().subtract(const Duration(days: 400));
      final result = DateTimeUtils.formatRelativeTime(yearsAgo);
      expect(result, contains('year'));
    });

    test('uses singular "year" for exactly 1 year ago', () {
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 366));
      final result = DateTimeUtils.formatRelativeTime(oneYearAgo);
      expect(result, equals('1 year ago'));
    });
  });

  // ---------------------------------------------------------------------------
  group('DateTimeUtils.getCurrentTimestamp', () {
    test('returns a non-zero unix timestamp close to now', () {
      final before = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final ts = DateTimeUtils.getCurrentTimestamp();
      final after = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      expect(ts, greaterThanOrEqualTo(before));
      expect(ts, lessThanOrEqualTo(after));
    });
  });
}
