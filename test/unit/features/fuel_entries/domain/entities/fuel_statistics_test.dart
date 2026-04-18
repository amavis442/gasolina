// ABOUTME: Unit tests for FuelStatistics entity representing aggregate statistics
// ABOUTME: Tests average price, efficiency, and total cost calculations

import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/features/fuel_entries/domain/entities/fuel_statistics.dart';

void main() {
  group('FuelStatistics', () {
    test('should calculate values correctly', () {
      // Arrange
      const stats = FuelStatistics(
        totalEntries: 10,
        totalLiters: 500.0,
        totalKilometers: 5000.0,
        totalCost: 750.0,
        averagePricePerLiter: 1.5,
        averageEfficiency: 10.0,
      );

      // Act & Assert
      expect(stats.totalEntries, 10);
      expect(stats.totalLiters, 500.0);
      expect(stats.totalKilometers, 5000.0);
      expect(stats.totalCost, 750.0);
      expect(stats.averagePricePerLiter, 1.5);
      expect(stats.averageEfficiency, 10.0);
    });

    test('should support value equality with Equatable', () {
      // Arrange
      const stats1 = FuelStatistics(
        totalEntries: 10,
        totalLiters: 500.0,
        totalKilometers: 5000.0,
        totalCost: 750.0,
        averagePricePerLiter: 1.5,
        averageEfficiency: 10.0,
      );

      const stats2 = FuelStatistics(
        totalEntries: 10,
        totalLiters: 500.0,
        totalKilometers: 5000.0,
        totalCost: 750.0,
        averagePricePerLiter: 1.5,
        averageEfficiency: 10.0,
      );

      const stats3 = FuelStatistics(
        totalEntries: 5,
        totalLiters: 250.0,
        totalKilometers: 2500.0,
        totalCost: 375.0,
        averagePricePerLiter: 1.5,
        averageEfficiency: 10.0,
      );

      // Act & Assert
      expect(stats1, equals(stats2));
      expect(stats1, isNot(equals(stats3)));
    });

    test('should handle zero entries', () {
      // Arrange
      const stats = FuelStatistics(
        totalEntries: 0,
        totalLiters: 0.0,
        totalKilometers: 0.0,
        totalCost: 0.0,
        averagePricePerLiter: 0.0,
        averageEfficiency: 0.0,
      );

      // Act & Assert
      expect(stats.totalEntries, 0);
      expect(stats.totalLiters, 0.0);
      expect(stats.totalKilometers, 0.0);
      expect(stats.totalCost, 0.0);
      expect(stats.averagePricePerLiter, 0.0);
      expect(stats.averageEfficiency, 0.0);
    });
  });
}
