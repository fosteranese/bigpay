import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/utils/date.util.dart';

void main() {
  group('DateUtil.time', () {
    test('formats a double-digit hour and minute', () {
      final input = DateTime(2026, 1, 1, 14, 30).toIso8601String();
      expect(DateUtil.time(input), '2:30 PM');
    });

    test('formats a single-digit hour and minute without going empty', () {
      // The historical bug: restringing date.hour/date.minute without
      // zero-padding (e.g. "9:5") broke the fixed-offset parser this used
      // to go through, silently producing '' instead of a real time.
      final input = DateTime(2026, 1, 1, 9, 5).toIso8601String();
      expect(DateUtil.time(input), '9:05 AM');
    });

    test('formats midnight and noon correctly', () {
      expect(
        DateUtil.time(DateTime(2026, 1, 1, 0, 0).toIso8601String()),
        '12:00 AM',
      );
      expect(
        DateUtil.time(DateTime(2026, 1, 1, 12, 0).toIso8601String()),
        '12:00 PM',
      );
    });

    test('returns empty for null or empty input', () {
      expect(DateUtil.time(null), '');
      expect(DateUtil.time(''), '');
    });
  });

  group('DateUtil.relative', () {
    test(
      "today's single-digit time still shows a time, not just a fallback",
      () {
        final now = DateTime.now();
        final input = DateTime(
          now.year,
          now.month,
          now.day,
          9,
          5,
        ).toIso8601String();
        expect(DateUtil.relative(input), '9:05 AM');
      },
    );
  });

  group('DateUtil.isSameDay', () {
    test('true for two timestamps on the same calendar day', () {
      expect(
        DateUtil.isSameDay(
          DateTime(2026, 3, 5, 8).toIso8601String(),
          DateTime(2026, 3, 5, 22).toIso8601String(),
        ),
        isTrue,
      );
    });

    test('false across a day boundary', () {
      expect(
        DateUtil.isSameDay(
          DateTime(2026, 3, 5, 23, 59).toIso8601String(),
          DateTime(2026, 3, 6, 0, 1).toIso8601String(),
        ),
        isFalse,
      );
    });

    test('false when either side fails to parse', () {
      expect(DateUtil.isSameDay('not a date', '2026-03-05'), isFalse);
      expect(DateUtil.isSameDay(null, '2026-03-05'), isFalse);
    });
  });
}
