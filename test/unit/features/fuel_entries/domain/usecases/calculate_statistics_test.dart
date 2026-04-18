// ABOUTME: Unit tests for CalculateStatistics use case
// ABOUTME: Tests statistics calculation from fuel entries

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/errors/failures.dart';
import 'package:gasolina/features/fuel_entries/domain/entities/fuel_entry.dart';
import 'package:gasolina/features/fuel_entries/domain/entities/fuel_statistics.dart';
import 'package:gasolina/features/fuel_entries/domain/usecases/calculate_statistics.dart';
import 'package:mockito/mockito.dart';

import 'get_all_fuel_entries_test.mocks.dart';

void main() {
  late CalculateStatistics useCase;
  late MockFuelEntryRepository mockRepository;

  setUp(() {
    mockRepository = MockFuelEntryRepository();
    useCase = CalculateStatistics(mockRepository);
  });

  test('should calculate statistics from all entries', () async {
    // Arrange
    final entries = [
      FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      ),
      FuelEntry(
        id: '2',
        date: DateTime(2026, 4, 2),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      ),
    ];

    when(mockRepository.getAllEntries())
        .thenAnswer((_) async => Right(entries));

    // Act
    final result = await useCase();

    // Assert
    expect(result, isA<Right<Failure, FuelStatistics>>());
    result.fold(
      (failure) => fail('Should not return failure'),
      (stats) {
        expect(stats.totalEntries, 2);
        expect(stats.totalLiters, 100.0);
        expect(stats.totalKilometers, 1000.0);
        expect(stats.totalCost, 150.0);
        expect(stats.averagePricePerLiter, 1.5);
        expect(stats.averageEfficiency, 10.0);
      },
    );

    verify(mockRepository.getAllEntries());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return zero statistics when no entries exist', () async {
    // Arrange
    when(mockRepository.getAllEntries())
        .thenAnswer((_) async => const Right([]));

    // Act
    final result = await useCase();

    // Assert
    expect(result, isA<Right<Failure, FuelStatistics>>());
    result.fold(
      (failure) => fail('Should not return failure'),
      (stats) {
        expect(stats.totalEntries, 0);
        expect(stats.totalLiters, 0.0);
        expect(stats.totalKilometers, 0.0);
        expect(stats.totalCost, 0.0);
        expect(stats.averagePricePerLiter, 0.0);
        expect(stats.averageEfficiency, 0.0);
      },
    );
  });

  test('should return failure when repository fails', () async {
    // Arrange
    when(mockRepository.getAllEntries())
        .thenAnswer((_) async => const Left(DatabaseFailure('Database error')));

    // Act
    final result = await useCase();

    // Assert
    expect(result, const Left(DatabaseFailure('Database error')));
    verify(mockRepository.getAllEntries());
    verifyNoMoreInteractions(mockRepository);
  });
}
