// ABOUTME: Utility functions for wage period date calculations
// ABOUTME: A wage period runs from the 25th of one month to the 24th of the next

import 'package:intl/intl.dart';

/// Returns the start (always a 25th) of the wage period the given date falls in.
/// Days 25–end belong to that month's period; days 1–24 belong to the prior month's period.
DateTime wagePeriodStart(DateTime date) {
  if (date.day >= 25) {
    return DateTime(date.year, date.month, 25);
  }
  // Dart normalises month 0 → December of the prior year automatically.
  return DateTime(date.year, date.month - 1, 25);
}

/// Human-readable label for the wage period starting on [start].
/// Same-year:  "25 Mar – 24 Apr 2026"
/// Year boundary: "25 Dec 2025 – 24 Jan 2026"
String wagePeriodLabel(DateTime start) {
  // Dart normalises month 13 → January of the next year automatically.
  final end = DateTime(start.year, start.month + 1, 24);
  if (start.year == end.year) {
    return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
  }
  return '${DateFormat('d MMM yyyy').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
}
