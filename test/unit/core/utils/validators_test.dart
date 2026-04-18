// ABOUTME: Unit tests for validation functions used in fuel entry forms
// ABOUTME: Tests date, numeric ranges, and suspicious value warnings

import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/utils/validators.dart';

void main() {
  group('DateValidator', () {
    test('should return null for valid date in the past', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateValidator.validate(yesterday), isNull);
    });

    test('should return null for today', () {
      final today = DateTime.now();
      expect(DateValidator.validate(today), isNull);
    });

    test('should return error for future date', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(DateValidator.validate(tomorrow), isNotNull);
      expect(DateValidator.validate(tomorrow), contains('future'));
    });
  });

  group('LitersValidator', () {
    test('should return null for valid liters', () {
      expect(LitersValidator.validate(50.0), isNull);
      expect(LitersValidator.validate(0.01), isNull);
      expect(LitersValidator.validate(200.0), isNull);
    });

    test('should return error for zero', () {
      expect(LitersValidator.validate(0.0), isNotNull);
      expect(LitersValidator.validate(0.0), contains('greater than 0'));
    });

    test('should return error for negative values', () {
      expect(LitersValidator.validate(-5.0), isNotNull);
      expect(LitersValidator.validate(-5.0), contains('greater than 0'));
    });

    test('should return error for values exceeding max', () {
      expect(LitersValidator.validate(201.0), isNotNull);
      expect(LitersValidator.validate(201.0), contains('200'));
    });
  });

  group('KilometersValidator', () {
    test('should return null for valid kilometers', () {
      expect(KilometersValidator.validate(100.0), isNull);
      expect(KilometersValidator.validate(0.1), isNull);
      expect(KilometersValidator.validate(2000.0), isNull);
    });

    test('should return error for zero', () {
      expect(KilometersValidator.validate(0.0), isNotNull);
      expect(KilometersValidator.validate(0.0), contains('greater than 0'));
    });

    test('should return error for negative values', () {
      expect(KilometersValidator.validate(-10.0), isNotNull);
      expect(KilometersValidator.validate(-10.0), contains('greater than 0'));
    });

    test('should return error for values exceeding max', () {
      expect(KilometersValidator.validate(2001.0), isNotNull);
      expect(KilometersValidator.validate(2001.0), contains('2000'));
    });
  });

  group('TotalCostValidator', () {
    test('should return null for valid cost', () {
      expect(TotalCostValidator.validate(50.0), isNull);
      expect(TotalCostValidator.validate(0.01), isNull);
    });

    test('should return error for zero', () {
      expect(TotalCostValidator.validate(0.0), isNotNull);
      expect(TotalCostValidator.validate(0.0), contains('greater than 0'));
    });

    test('should return error for negative values', () {
      expect(TotalCostValidator.validate(-5.0), isNotNull);
      expect(TotalCostValidator.validate(-5.0), contains('greater than 0'));
    });
  });

  group('PricePerLiterValidator', () {
    test('should return null for normal price', () {
      expect(PricePerLiterValidator.validate(1.50), isNull);
      expect(PricePerLiterValidator.validate(2.00), isNull);
    });

    test('should return warning for suspiciously low price', () {
      expect(PricePerLiterValidator.validate(0.30), isNotNull);
      expect(PricePerLiterValidator.validate(0.30), contains('suspicious'));
    });

    test('should return warning for suspiciously high price', () {
      expect(PricePerLiterValidator.validate(6.00), isNotNull);
      expect(PricePerLiterValidator.validate(6.00), contains('suspicious'));
    });

    test('should accept edge values', () {
      expect(PricePerLiterValidator.validate(0.50), isNull);
      expect(PricePerLiterValidator.validate(5.00), isNull);
    });
  });

  group('EfficiencyValidator', () {
    test('should return null for normal efficiency', () {
      expect(EfficiencyValidator.validate(10.0), isNull);
      expect(EfficiencyValidator.validate(15.0), isNull);
    });

    test('should return warning for suspiciously low efficiency', () {
      expect(EfficiencyValidator.validate(2.0), isNotNull);
      expect(EfficiencyValidator.validate(2.0), contains('suspicious'));
    });

    test('should return warning for suspiciously high efficiency', () {
      expect(EfficiencyValidator.validate(35.0), isNotNull);
      expect(EfficiencyValidator.validate(35.0), contains('suspicious'));
    });

    test('should accept edge values', () {
      expect(EfficiencyValidator.validate(3.0), isNull);
      expect(EfficiencyValidator.validate(30.0), isNull);
    });
  });
}
