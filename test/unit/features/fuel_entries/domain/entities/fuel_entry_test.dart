// ABOUTME: Unit tests for FuelEntry entity, testing calculated properties and value equality
// ABOUTME: Validates pricePerLiter, efficiency, and costPerKilometer calculations

import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/features/fuel_entries/domain/entities/fuel_entry.dart';

void main() {
  group('FuelEntry', () {
    test('should calculate pricePerLiter correctly', () {
      // Arrange
      final entry = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      // Act
      final pricePerLiter = entry.pricePerLiter;

      // Assert
      expect(pricePerLiter, 1.5);
    });

    test('should calculate efficiency (km/l) correctly', () {
      // Arrange
      final entry = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      // Act
      final efficiency = entry.efficiency;

      // Assert
      expect(efficiency, 10.0);
    });

    test('should calculate costPerKilometer correctly', () {
      // Arrange
      final entry = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      // Act
      final costPerKilometer = entry.costPerKilometer;

      // Assert
      expect(costPerKilometer, 0.15);
    });

    test('should handle decimal values in calculations', () {
      // Arrange
      final entry = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 45.75,
        kilometers: 523.3,
        totalCost: 68.89,
      );

      // Act & Assert
      expect(entry.pricePerLiter, closeTo(1.506, 0.01));
      expect(entry.efficiency, closeTo(11.438, 0.01));
      expect(entry.costPerKilometer, closeTo(0.132, 0.01));
    });

    test('should support value equality with Equatable', () {
      // Arrange
      final entry1 = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      final entry2 = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      final entry3 = FuelEntry(
        id: '2',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      // Act & Assert
      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
    });

    test('should have immutable properties', () {
      // Arrange
      final date = DateTime(2026, 4, 1);
      final entry = FuelEntry(
        id: '1',
        date: date,
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      // Act & Assert
      expect(entry.id, '1');
      expect(entry.date, date);
      expect(entry.liters, 50.0);
      expect(entry.kilometers, 500.0);
      expect(entry.totalCost, 75.0);
    });
  });
}
