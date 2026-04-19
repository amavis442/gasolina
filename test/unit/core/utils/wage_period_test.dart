// ABOUTME: Unit tests for wage period start and label utilities
// ABOUTME: Covers normal months, boundary days, year-crossing periods, and custom wage days

import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/utils/wage_period.dart';

void main() {
  group('wagePeriodStart — default day 25', () {
    test('day < 25 belongs to previous month period', () {
      expect(wagePeriodStart(DateTime(2026, 4, 10), 25), DateTime(2026, 3, 25));
    });

    test('day == 24 (last day before cutover) belongs to previous month', () {
      expect(wagePeriodStart(DateTime(2026, 4, 24), 25), DateTime(2026, 3, 25));
    });

    test('day == 25 starts a new period', () {
      expect(wagePeriodStart(DateTime(2026, 4, 25), 25), DateTime(2026, 4, 25));
    });

    test('day > 25 belongs to same month period', () {
      expect(wagePeriodStart(DateTime(2026, 4, 30), 25), DateTime(2026, 4, 25));
    });

    test('January day < 25 crosses year boundary to December', () {
      expect(wagePeriodStart(DateTime(2026, 1, 10), 25), DateTime(2025, 12, 25));
    });

    test('January day >= 25 stays in January', () {
      expect(wagePeriodStart(DateTime(2026, 1, 25), 25), DateTime(2026, 1, 25));
    });

    test('December day >= 25 starts December period', () {
      expect(wagePeriodStart(DateTime(2025, 12, 31), 25), DateTime(2025, 12, 25));
    });
  });

  group('wagePeriodStart — custom wage days', () {
    test('wage day 1: day 1 starts a new period', () {
      expect(wagePeriodStart(DateTime(2026, 4, 1), 1), DateTime(2026, 4, 1));
    });

    test('wage day 28: day 27 belongs to previous month', () {
      expect(wagePeriodStart(DateTime(2026, 4, 27), 28), DateTime(2026, 3, 28));
    });

    test('wage day 28: day 28 starts new period', () {
      expect(wagePeriodStart(DateTime(2026, 4, 28), 28), DateTime(2026, 4, 28));
    });

    test('wage day 23: January day 22 crosses to December', () {
      expect(wagePeriodStart(DateTime(2026, 1, 22), 23), DateTime(2025, 12, 23));
    });
  });

  group('wagePeriodLabel', () {
    test('same-year period omits start year', () {
      expect(wagePeriodLabel(DateTime(2026, 3, 25), 25), '25 Mar – 24 Apr 2026');
    });

    test('year-crossing period includes both years', () {
      expect(wagePeriodLabel(DateTime(2025, 12, 25), 25), '25 Dec 2025 – 24 Jan 2026');
    });

    test('period start in November stays same year', () {
      expect(wagePeriodLabel(DateTime(2026, 11, 25), 25), '25 Nov – 24 Dec 2026');
    });

    test('wage day 23 produces correct end day', () {
      expect(wagePeriodLabel(DateTime(2026, 3, 23), 23), '23 Mar – 22 Apr 2026');
    });

    test('wage day 28 year-crossing period', () {
      expect(wagePeriodLabel(DateTime(2025, 12, 28), 28), '28 Dec 2025 – 27 Jan 2026');
    });
  });
}
