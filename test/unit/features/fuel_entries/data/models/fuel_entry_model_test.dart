// ABOUTME: Unit tests for FuelEntryModel JSON serialization and deserialization
// ABOUTME: Validates conversion to/from JSON and entity mapping

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/features/fuel_entries/data/models/fuel_entry_model.dart';
import 'package:gasolina/features/fuel_entries/domain/entities/fuel_entry.dart';

void main() {
  group('FuelEntryModel', () {
    final testDate = DateTime(2026, 4, 1, 10, 30);
    final testModel = FuelEntryModel(
      id: '1',
      date: testDate,
      liters: 50.0,
      kilometers: 500.0,
      totalCost: 75.0,
    );

    test('should be a subclass of FuelEntry entity', () {
      expect(testModel, isA<FuelEntry>());
    });

    test('should convert from JSON correctly', () {
      // Arrange
      final jsonMap = {
        'id': '1',
        'date': testDate.millisecondsSinceEpoch,
        'liters': 50.0,
        'kilometers': 500.0,
        'total_cost': 75.0,
      };

      // Act
      final result = FuelEntryModel.fromJson(jsonMap);

      // Assert
      expect(result.id, '1');
      expect(result.date, testDate);
      expect(result.liters, 50.0);
      expect(result.kilometers, 500.0);
      expect(result.totalCost, 75.0);
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = testModel.toJson();

      // Assert
      expect(result['id'], '1');
      expect(result['date'], testDate.millisecondsSinceEpoch);
      expect(result['liters'], 50.0);
      expect(result['kilometers'], 500.0);
      expect(result['total_cost'], 75.0);
    });

    test('should convert to JSON and back without data loss', () {
      // Act
      final json = testModel.toJson();
      final result = FuelEntryModel.fromJson(json);

      // Assert
      expect(result, equals(testModel));
    });

    test('should handle JSON string conversion', () {
      // Arrange
      final jsonString = json.encode(testModel.toJson());

      // Act
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final result = FuelEntryModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(testModel));
    });

    test('should convert from entity', () {
      // Arrange
      final entity = FuelEntry(
        id: '2',
        date: testDate,
        liters: 45.5,
        kilometers: 450.0,
        totalCost: 68.25,
      );

      // Act
      final result = FuelEntryModel.fromEntity(entity);

      // Assert
      expect(result, isA<FuelEntryModel>());
      expect(result.id, entity.id);
      expect(result.date, entity.date);
      expect(result.liters, entity.liters);
      expect(result.kilometers, entity.kilometers);
      expect(result.totalCost, entity.totalCost);
    });

    test('should preserve calculated properties from parent entity', () {
      // Arrange & Act
      final model = FuelEntryModel(
        id: '1',
        date: testDate,
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      // Assert
      expect(model.pricePerLiter, 1.5);
      expect(model.efficiency, 10.0);
      expect(model.costPerKilometer, 0.15);
    });
  });
}
