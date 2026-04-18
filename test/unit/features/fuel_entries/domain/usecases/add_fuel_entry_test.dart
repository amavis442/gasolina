// ABOUTME: Unit tests for AddFuelEntry use case with mocked repository
// ABOUTME: Tests entry addition and error handling

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/errors/failures.dart';
import 'package:gasolina/features/fuel_entries/domain/entities/fuel_entry.dart';
import 'package:gasolina/features/fuel_entries/domain/repositories/fuel_entry_repository.dart';
import 'package:gasolina/features/fuel_entries/domain/usecases/add_fuel_entry.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_all_fuel_entries_test.mocks.dart';

@GenerateMocks([FuelEntryRepository])
void main() {
  late AddFuelEntry useCase;
  late MockFuelEntryRepository mockRepository;

  setUp(() {
    mockRepository = MockFuelEntryRepository();
    useCase = AddFuelEntry(mockRepository);
  });

  test('should add fuel entry through repository', () async {
    // Arrange
    final entry = FuelEntry(
      id: '1',
      date: DateTime(2026, 4, 1),
      liters: 50.0,
      kilometers: 500.0,
      totalCost: 75.0,
    );

    when(mockRepository.addEntry(entry))
        .thenAnswer((_) async => Right(entry));

    // Act
    final result = await useCase(entry);

    // Assert
    expect(result, Right(entry));
    verify(mockRepository.addEntry(entry));
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

    when(mockRepository.addEntry(entry))
        .thenAnswer((_) async => const Left(DatabaseFailure('Failed to add')));

    // Act
    final result = await useCase(entry);

    // Assert
    expect(result, const Left(DatabaseFailure('Failed to add')));
    verify(mockRepository.addEntry(entry));
    verifyNoMoreInteractions(mockRepository);
  });
}
