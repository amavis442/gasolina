// ABOUTME: Unit tests for local datasource with in-memory SQLite database
// ABOUTME: Tests CRUD operations without requiring file system access

import 'package:flutter_test/flutter_test.dart';
import 'package:gasolina/core/errors/exceptions.dart';
import 'package:gasolina/features/fuel_entries/data/datasources/fuel_entry_local_datasource.dart';
import 'package:gasolina/features/fuel_entries/data/models/fuel_entry_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late FuelEntryLocalDataSource dataSource;
  late Database database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fuel_entries (
            id TEXT PRIMARY KEY,
            date INTEGER NOT NULL,
            liters REAL NOT NULL CHECK(liters > 0),
            kilometers REAL NOT NULL CHECK(kilometers > 0),
            total_cost REAL NOT NULL CHECK(total_cost > 0),
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_fuel_entries_date ON fuel_entries(date DESC)
        ''');
      },
    );
    dataSource = FuelEntryLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('addEntry', () {
    test('should add entry to database and return it', () async {
      // Arrange
      final entry = FuelEntryModel(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      // Act
      final result = await dataSource.addEntry(entry);

      // Assert
      expect(result, equals(entry));

      final allEntries = await dataSource.getAllEntries();
      expect(allEntries.length, 1);
      expect(allEntries.first, equals(entry));
    });

    test('should throw DataException on duplicate ID', () async {
      // Arrange
      final entry = FuelEntryModel(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      await dataSource.addEntry(entry);

      // Act & Assert
      expect(
        () => dataSource.addEntry(entry),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('getAllEntries', () {
    test('should return empty list when no entries exist', () async {
      // Act
      final result = await dataSource.getAllEntries();

      // Assert
      expect(result, isEmpty);
    });

    test('should return all entries sorted by date descending', () async {
      // Arrange
      final entry1 = FuelEntryModel(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      final entry2 = FuelEntryModel(
        id: '2',
        date: DateTime(2026, 4, 5),
        liters: 45.0,
        kilometers: 450.0,
        totalCost: 67.5,
      );

      final entry3 = FuelEntryModel(
        id: '3',
        date: DateTime(2026, 4, 3),
        liters: 48.0,
        kilometers: 480.0,
        totalCost: 72.0,
      );

      await dataSource.addEntry(entry1);
      await dataSource.addEntry(entry2);
      await dataSource.addEntry(entry3);

      // Act
      final result = await dataSource.getAllEntries();

      // Assert
      expect(result.length, 3);
      expect(result[0].id, '2'); // Most recent first
      expect(result[1].id, '3');
      expect(result[2].id, '1');
    });
  });

  group('getEntryById', () {
    test('should return entry when it exists', () async {
      // Arrange
      final entry = FuelEntryModel(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      await dataSource.addEntry(entry);

      // Act
      final result = await dataSource.getEntryById('1');

      // Assert
      expect(result, equals(entry));
    });

    test('should throw DataException when entry does not exist', () async {
      // Act & Assert
      expect(
        () => dataSource.getEntryById('nonexistent'),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('updateEntry', () {
    test('should update existing entry and return it', () async {
      // Arrange
      final entry = FuelEntryModel(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      await dataSource.addEntry(entry);

      final updatedEntry = FuelEntryModel(
        id: '1',
        date: DateTime(2026, 4, 2),
        liters: 45.0,
        kilometers: 450.0,
        totalCost: 67.5,
      );

      // Act
      final result = await dataSource.updateEntry(updatedEntry);

      // Assert
      expect(result, equals(updatedEntry));

      final retrieved = await dataSource.getEntryById('1');
      expect(retrieved, equals(updatedEntry));
    });

    test('should throw DataException when entry does not exist', () async {
      // Arrange
      final entry = FuelEntryModel(
        id: 'nonexistent',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      // Act & Assert
      expect(
        () => dataSource.updateEntry(entry),
        throwsA(isA<DataException>()),
      );
    });
  });

  group('deleteEntry', () {
    test('should delete existing entry', () async {
      // Arrange
      final entry = FuelEntryModel(
        id: '1',
        date: DateTime(2026, 4, 1),
        liters: 50.0,
        kilometers: 500.0,
        totalCost: 75.0,
      );

      await dataSource.addEntry(entry);

      // Act
      await dataSource.deleteEntry('1');

      // Assert
      final allEntries = await dataSource.getAllEntries();
      expect(allEntries, isEmpty);
    });

    test('should throw DataException when entry does not exist', () async {
      // Act & Assert
      expect(
        () => dataSource.deleteEntry('nonexistent'),
        throwsA(isA<DataException>()),
      );
    });
  });
}
