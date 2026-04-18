// ABOUTME: Unit tests for repository implementation with mocked datasource
// ABOUTME: Tests Either<Failure, Result> error handling and datasource integration

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/errors/exceptions.dart';
import 'package:gasolina/core/errors/failures.dart';
import 'package:gasolina/features/fuel_entries/data/datasources/fuel_entry_local_datasource.dart';
import 'package:gasolina/features/fuel_entries/data/models/fuel_entry_model.dart';
import 'package:gasolina/features/fuel_entries/data/repositories/fuel_entry_repository_impl.dart';
import 'package:gasolina/features/fuel_entries/domain/entities/fuel_entry.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'fuel_entry_repository_impl_test.mocks.dart';

@GenerateMocks([FuelEntryLocalDataSource])
void main() {
  late FuelEntryRepositoryImpl repository;
  late MockFuelEntryLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockFuelEntryLocalDataSource();
    repository = FuelEntryRepositoryImpl(mockDataSource);
  });

  group('getAllEntries', () {
    test('should return list of entries when datasource succeeds', () async {
      // Arrange
      final testModels = [
        FuelEntryModel(
          id: '1',
          date: DateTime(2026, 4, 1),
          liters: 50.0,
          kilometers: 500.0,
          totalCost: 75.0,
        ),
        FuelEntryModel(
          id: '2',
          date: DateTime(2026, 4, 2),
          liters: 45.0,
          kilometers: 450.0,
          totalCost: 67.5,
        ),
      ];

      when(mockDataSource.getAllEntries())
          .thenAnswer((_) async => testModels);

      // Act
      final result = await repository.getAllEntries();

      // Assert
      expect(result, isA<Right<Failure, List<FuelEntry>>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (entries) {
          expect(entries.length, 2);
          expect(entries[0].id, '1');
          expect(entries[1].id, '2');
        },
      );

      verify(mockDataSource.getAllEntries());
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should return DatabaseFailure when datasource throws', () async {
      // Arrange
      when(mockDataSource.getAllEntries())
          .thenThrow(DataException('Database error'));

      // Act
      final result = await repository.getAllEntries();

      // Assert
      expect(result, isA<Left<Failure, List<FuelEntry>>>());
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (entries) => fail('Should not return success'),
      );

      verify(mockDataSource.getAllEntries());
      verifyNoMoreInteractions(mockDataSource);
    });
  });

  group('getEntryById', () {
    test('should return entry when datasource succeeds', () async {
      // Arrange
      final testModel = FuelEntryModel(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      when(mockDataSource.getEntryById('1'))
          .thenAnswer((_) async => testModel);

      // Act
      final result = await repository.getEntryById('1');

      // Assert
      expect(result, isA<Right<Failure, FuelEntry>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (entry) => expect(entry.id, '1'),
      );

      verify(mockDataSource.getEntryById('1'));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should return DatabaseFailure when entry not found', () async {
      // Arrange
      when(mockDataSource.getEntryById('1'))
          .thenThrow(DataException('Entry not found'));

      // Act
      final result = await repository.getEntryById('1');

      // Assert
      expect(result, isA<Left<Failure, FuelEntry>>());
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Entry not found');
        },
        (entry) => fail('Should not return success'),
      );
    });
  });

  group('addEntry', () {
    test('should return added entry when datasource succeeds', () async {
      // Arrange
      final entry = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      final model = FuelEntryModel.fromEntity(entry);

      when(mockDataSource.addEntry(any))
          .thenAnswer((_) async => model);

      // Act
      final result = await repository.addEntry(entry);

      // Assert
      expect(result, isA<Right<Failure, FuelEntry>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (addedEntry) => expect(addedEntry.id, '1'),
      );

      verify(mockDataSource.addEntry(any));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should return DatabaseFailure when datasource throws', () async {
      // Arrange
      final entry = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      when(mockDataSource.addEntry(any))
          .thenThrow(DataException('Failed to add entry'));

      // Act
      final result = await repository.addEntry(entry);

      // Assert
      expect(result, isA<Left<Failure, FuelEntry>>());
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Failed to add entry');
        },
        (entry) => fail('Should not return success'),
      );
    });
  });

  group('updateEntry', () {
    test('should return updated entry when datasource succeeds', () async {
      // Arrange
      final entry = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      final model = FuelEntryModel.fromEntity(entry);

      when(mockDataSource.updateEntry(any))
          .thenAnswer((_) async => model);

      // Act
      final result = await repository.updateEntry(entry);

      // Assert
      expect(result, isA<Right<Failure, FuelEntry>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (updatedEntry) => expect(updatedEntry.id, '1'),
      );

      verify(mockDataSource.updateEntry(any));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should return DatabaseFailure when datasource throws', () async {
      // Arrange
      final entry = FuelEntry(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      when(mockDataSource.updateEntry(any))
          .thenThrow(DataException('Failed to update entry'));

      // Act
      final result = await repository.updateEntry(entry);

      // Assert
      expect(result, isA<Left<Failure, FuelEntry>>());
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Failed to update entry');
        },
        (entry) => fail('Should not return success'),
      );
    });
  });

  group('deleteEntry', () {
    test('should return unit when datasource succeeds', () async {
      // Arrange
      when(mockDataSource.deleteEntry('1'))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.deleteEntry('1');

      // Assert
      expect(result, isA<Right<Failure, Unit>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (unit) => expect(unit, equals(unit)),
      );

      verify(mockDataSource.deleteEntry('1'));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should return DatabaseFailure when datasource throws', () async {
      // Arrange
      when(mockDataSource.deleteEntry('1'))
          .thenThrow(DataException('Failed to delete entry'));

      // Act
      final result = await repository.deleteEntry('1');

      // Assert
      expect(result, isA<Left<Failure, Unit>>());
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Failed to delete entry');
        },
        (unit) => fail('Should not return success'),
      );
    });
  });
}
