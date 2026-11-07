import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calendar-based Daily Verse Tests', () {
    test('Calculates deterministic daily verse index for calendar dates', () {
      final date1 = DateTime(2026, 11, 5);
      final date2 = DateTime(2026, 11, 6);

      final start1 = DateTime(date1.year, 1, 1);
      final dayOfYear1 = date1.difference(start1).inDays;
      final seed1 = (date1.year * 365) + dayOfYear1;

      final start2 = DateTime(date2.year, 1, 1);
      final dayOfYear2 = date2.difference(start2).inDays;
      final seed2 = (date2.year * 365) + dayOfYear2;

      expect(seed1 != seed2, isTrue);
      expect(seed2 - seed1, equals(1));
    });
  });
}

