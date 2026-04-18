// ABOUTME: Unit tests for GetAllFuelEntries use case with mocked repository
// ABOUTME: Tests successful retrieval and error handling

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/errors/failures.dart';
import 'package:gasolina/features/fuel_entries/domain/entities/fuel_entry.dart';
import 'package:gasolina/features/fuel_entries/domain/repositories/fuel_entry_repository.dart';
import 'package:gasolina/features/fuel_entries/domain/usecases/get_all_fuel_entries.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_all_fuel_entries_test.mocks.dart';

@GenerateMocks([FuelEntryRepository])
void main() {
  late GetAllFuelEntries useCase;
  late MockFuelEntryRepository mockRepository;

  setUp(() {
    mockRepository = MockFuelEntryRepository();
    useCase = GetAllFuelEntries(mockRepository);
  });

  test('should get all fuel entries from repository', () async {
    // Arrange
    final testEntries = [
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
        liters: 45.0,
        kilometers: 450.0,
        totalCost: 67.5,
      ),
    ];

    when(mockRepository.getAllEntries())
        .thenAnswer((_) async => Right(testEntries));

    // Act
    final result = await useCase();

    // Assert
    expect(result, Right(testEntries));
    verify(mockRepository.getAllEntries());
    verifyNoMoreInteractions(mockRepository);
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
