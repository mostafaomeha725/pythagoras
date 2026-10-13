import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test(
      'formatYMDWithTime formats ISO 8601 UTC timestamp with date and time',
      () {
        const utcString = '2026-10-13T17:09:00.000000Z';
        final formatted = DateFormatter.formatYMDWithTime(utcString);

        // Verify it produces year/month/day and time with period
        expect(formatted, contains('2026/10/13'));
        expect(formatted, contains('-'));
        expect(formatted, anyOf(contains('م'), contains('ص')));
      },
    );

    test(
      'formatYMDWithTime handles date-only strings without adding bogus time',
      () {
        const dateOnly = '2026-10-13';
        final formatted = DateFormatter.formatYMDWithTime(dateOnly);

        expect(formatted, equals('2026/10/13'));
      },
    );

    test('formatYMDWithTime returns empty string for null or empty input', () {
      expect(DateFormatter.formatYMDWithTime(null), equals(''));
      expect(DateFormatter.formatYMDWithTime(''), equals(''));
    });

    test(
      'formatYMDWithTime returns original string on invalid date format',
      () {
        const invalid = 'invalid-date-string';
        expect(DateFormatter.formatYMDWithTime(invalid), equals(invalid));
      },
    );
  });
}
