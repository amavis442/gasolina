// ABOUTME: Unit tests for wage period start and label utilities
// ABOUTME: Covers normal months, boundary days (24th, 25th), and year-crossing periods

import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/utils/wage_period.dart';

void main() {
  group('wagePeriodStart', () {
    test('day < 25 belongs to previous month period', () {
      final date = DateTime(2026, 4, 10);
      final start = wagePeriodStart(date);
      expect(start, DateTime(2026, 3, 25));
    });

    test('day == 24 (last day before cutover) belongs to previous month', () {
      final date = DateTime(2026, 4, 24);
      final start = wagePeriodStart(date);
      expect(start, DateTime(2026, 3, 25));
    });

    test('day == 25 starts a new period', () {
      final date = DateTime(2026, 4, 25);
      final start = wagePeriodStart(date);
      expect(start, DateTime(2026, 4, 25));
    });

    test('day > 25 belongs to same month period', () {
      final date = DateTime(2026, 4, 30);
      final start = wagePeriodStart(date);
      expect(start, DateTime(2026, 4, 25));
    });

    test('January day < 25 crosses year boundary to December', () {
      final date = DateTime(2026, 1, 10);
      final start = wagePeriodStart(date);
      expect(start, DateTime(2025, 12, 25));
    });

    test('January day >= 25 stays in January', () {
      final date = DateTime(2026, 1, 25);
      final start = wagePeriodStart(date);
      expect(start, DateTime(2026, 1, 25));
    });

    test('December day >= 25 starts December period', () {
      final date = DateTime(2025, 12, 31);
      final start = wagePeriodStart(date);
      expect(start, DateTime(2025, 12, 25));
    });
  });

  group('wagePeriodLabel', () {
    test('same-year period omits start year', () {
      final start = DateTime(2026, 3, 25);
      final label = wagePeriodLabel(start);
      expect(label, '25 Mar – 24 Apr 2026');
    });

    test('year-crossing period includes both years', () {
      final start = DateTime(2025, 12, 25);
      final label = wagePeriodLabel(start);
      expect(label, '25 Dec 2025 – 24 Jan 2026');
    });

    test('period start in November stays same year', () {
      final start = DateTime(2026, 11, 25);
      final label = wagePeriodLabel(start);
      expect(label, '25 Nov – 24 Dec 2026');
    });
  });
}
