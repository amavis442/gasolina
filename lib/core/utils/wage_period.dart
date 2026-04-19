// ABOUTME: Utility functions for wage period date calculations
// ABOUTME: A wage period runs from the configured wage day of one month to the day before in the next

import 'package:intl/intl.dart';

/// Returns the start of the wage period the given [date] falls in.
/// Days >= [wageDay] belong to that month's period; earlier days belong to the prior month's period.
/// Dart normalises month 0 → December of the prior year automatically.
DateTime wagePeriodStart(DateTime date, int wageDay) {
  if (date.day >= wageDay) {
    return DateTime(date.year, date.month, wageDay);
  }
  return DateTime(date.year, date.month - 1, wageDay);
}

/// Human-readable label for the wage period starting on [start] with the given [wageDay].
/// Same-year:     "25 Mar – 24 Apr 2026"
/// Year boundary: "25 Dec 2025 – 24 Jan 2026"
/// When wageDay == 1 the end is the last day of the same month (Dart normalises day 0).
String wagePeriodLabel(DateTime start, int wageDay) {
  final end = DateTime(start.year, start.month + 1, wageDay - 1);
  if (start.year == end.year) {
    return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
  }
  return '${DateFormat('d MMM yyyy').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
}
