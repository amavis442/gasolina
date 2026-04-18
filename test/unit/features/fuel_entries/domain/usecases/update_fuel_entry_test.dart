// ABOUTME: Unit tests for UpdateFuelEntry use case with mocked repository
// ABOUTME: Tests entry update and error handling

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/errors/failures.dart';
import 'package:gasolina/features/fuel_entries/domain/entities/fuel_entry.dart';
import 'package:gasolina/features/fuel_entries/domain/usecases/update_fuel_entry.dart';
import 'package:mockito/mockito.dart';

import 'get_all_fuel_entries_test.mocks.dart';

void main() {
  late UpdateFuelEntry useCase;
  late MockFuelEntryRepository mockRepository;

  setUp(() {
    mockRepository = MockFuelEntryRepository();
    useCase = UpdateFuelEntry(mockRepository);
  });

  test('should update fuel entry through repository', () async {
    // Arrange
    final entry = FuelEntry(
      id: '1',
      date: DateTime(2026, 4, 1),
      liters: 50.0,
      kilometers: 500.0,
      totalCost: 75.0,
    );

    when(mockRepository.updateEntry(entry))
        .thenAnswer((_) async => Right(entry));

    // Act
    final result = await useCase(entry);

    // Assert
    expect(result, Right(entry));
    verify(mockRepository.updateEntry(entry));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    final entry = FuelEntry(
      id: '1',
      date: DateTime(2026, 4, 1),
      liters: 50.0,
      kilometers: 500.0,
      totalCost: 75.0,
    );

    when(mockRepository.updateEntry(entry))
        .thenAnswer((_) async => const Left(DatabaseFailure('Failed to update')));

    // Act
    final result = await useCase(entry);

    // Assert
    expect(result, const Left(DatabaseFailure('Failed to update')));
    verify(mockRepository.updateEntry(entry));
    verifyNoMoreInteractions(mockRepository);
  });
}
