// ABOUTME: Input validation functions for fuel entry form fields
// ABOUTME: Validates date, numeric ranges, and provides warnings for suspicious values

class DateValidator {
  static String? validate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (date.isAfter(today)) {
      return 'Date cannot be in the future';
    }

    return null;
  }
}

class LitersValidator {
  static const double maxLiters = 200.0;

  static String? validate(double? value) {
    if (value == null || value <= 0) {
      return 'Liters must be greater than 0';
    }

    if (value > maxLiters) {
      return 'Liters cannot exceed $maxLiters';
    }

    return null;
  }
}

class KilometersValidator {
  static const double maxKilometers = 2000.0;

  static String? validate(double? value) {
    if (value == null || value <= 0) {
      return 'Kilometers must be greater than 0';
    }

    if (value > maxKilometers) {
      return 'Kilometers cannot exceed $maxKilometers';
    }

    return null;
  }
}

class TotalCostValidator {
  static String? validate(double? value) {
    if (value == null || value <= 0) {
      return 'Total cost must be greater than 0';
    }

    return null;
  }
}

class PricePerLiterValidator {
  static const double minNormalPrice = 0.50;
  static const double maxNormalPrice = 5.00;

  static String? validate(double value) {
    if (value < minNormalPrice || value > maxNormalPrice) {
      return 'Price per liter seems suspicious (€${value.toStringAsFixed(2)}/L)';
    }

    return null;
  }
}

class EfficiencyValidator {
  static const double minNormalEfficiency = 3.0;
  static const double maxNormalEfficiency = 30.0;

  static String? validate(double value) {
    if (value < minNormalEfficiency || value > maxNormalEfficiency) {
      return 'Efficiency seems suspicious (${value.toStringAsFixed(1)} km/L)';
    }

    return null;
  }
}
