// ABOUTME: Unit tests for DeleteFuelEntry use case with mocked repository
// ABOUTME: Tests entry deletion and error handling

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/errors/failures.dart';
import 'package:gasolina/features/fuel_entries/domain/usecases/delete_fuel_entry.dart';
import 'package:mockito/mockito.dart';

import 'get_all_fuel_entries_test.mocks.dart';

void main() {
  late DeleteFuelEntry useCase;
  late MockFuelEntryRepository mockRepository;

  setUp(() {
    mockRepository = MockFuelEntryRepository();
    useCase = DeleteFuelEntry(mockRepository);
  });

  test('should delete fuel entry through repository', () async {
    // Arrange
    const id = '1';

    when(mockRepository.deleteEntry(id))
        .thenAnswer((_) async => const Right(unit));

    // Act
    final result = await useCase(id);

    // Assert
    expect(result, const Right(unit));
    verify(mockRepository.deleteEntry(id));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    const id = '1';

    when(mockRepository.deleteEntry(id))
        .thenAnswer((_) async => const Left(DatabaseFailure('Failed to delete')));

    // Act
    final result = await useCase(id);

    // Assert
    expect(result, const Left(DatabaseFailure('Failed to delete')));
    verify(mockRepository.deleteEntry(id));
    verifyNoMoreInteractions(mockRepository);
  });
}
