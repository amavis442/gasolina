// ABOUTME: Unit tests for database migration system functionality
// ABOUTME: Tests v1 to v2 upgrade path, data preservation, and migration tracking

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gasolina/core/database/migrations/migration_registry.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Migration Tests', () {
    late Database testDb;

    setUp(() async {
      testDb = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );
    });

    tearDown(() async {
      await testDb.close();
    });

    test('V1 database schema creates fuel_entries table', () async {
      // Create a v1 database manually
      await testDb.execute('''
        CREATE TABLE fuel_entries (
          id TEXT PRIMARY KEY,
          date INTEGER NOT NULL,
          liters REAL NOT NULL CHECK(liters > 0),
          kilometers REAL NOT NULL CHECK(kilometers > 0),
          total_cost REAL NOT NULL CHECK(total_cost > 0),
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await testDb.execute('''
        CREATE INDEX idx_fuel_entries_date ON fuel_entries(date DESC)
      ''');

      // Verify table exists
      final tables = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='fuel_entries'"
      );

      expect(tables.length, 1);
      expect(tables.first['name'], 'fuel_entries');
    });

    test('V1 to V2 migration preserves existing data', () async {
      // Create v1 schema
      await testDb.execute('''
        CREATE TABLE fuel_entries (
          id TEXT PRIMARY KEY,
          date INTEGER NOT NULL,
          liters REAL NOT NULL CHECK(liters > 0),
          kilometers REAL NOT NULL CHECK(kilometers > 0),
          total_cost REAL NOT NULL CHECK(total_cost > 0),
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Insert test data
      final now = DateTime.now().millisecondsSinceEpoch;
      await testDb.insert('fuel_entries', {
        'id': 'test-1',
        'date': now,
        'liters': 45.5,
        'kilometers': 550.0,
        'total_cost': 75.25,
        'created_at': now,
        'updated_at': now,
      });

      await testDb.insert('fuel_entries', {
        'id': 'test-2',
        'date': now - 86400000,
        'liters': 40.0,
        'kilometers': 500.0,
        'total_cost': 68.00,
        'created_at': now,
        'updated_at': now,
      });

      // Get count before migration
      final beforeResult = await testDb.rawQuery('SELECT COUNT(*) as count FROM fuel_entries');
      final beforeCount = beforeResult.first['count'] as int;
      expect(beforeCount, 2);

      // Run V2 migration (add schema_migrations table)
      final v2Migration = MigrationRegistry.getMigrationsFrom(1)
          .firstWhere((m) => m.version == 2);

      await testDb.transaction((txn) async {
        await v2Migration.up(txn);
        await txn.insert('schema_migrations', {
          'version': v2Migration.version,
          'description': v2Migration.description,
          'applied_at': DateTime.now().millisecondsSinceEpoch,
        });
      });

      // Verify data still exists
      final afterResult = await testDb.rawQuery('SELECT COUNT(*) as count FROM fuel_entries');
      final afterCount = afterResult.first['count'] as int;
      expect(afterCount, 2);

      // Verify specific data
      final entries = await testDb.query('fuel_entries', orderBy: 'date DESC');
      expect(entries.length, 2);
      expect(entries[0]['id'], 'test-1');
      expect(entries[0]['liters'], 45.5);
      expect(entries[1]['id'], 'test-2');
      expect(entries[1]['kilometers'], 500.0);

      // Verify schema_migrations table exists and has correct data
      final migrations = await testDb.query('schema_migrations');
      expect(migrations.length, 1);
      expect(migrations[0]['version'], 2);
      expect(migrations[0]['description'], 'Add schema_migrations table for version tracking');
    });

    test('MigrationRegistry returns correct pending migrations', () {
      // From version 0 (fresh install)
      final freshMigrations = MigrationRegistry.getMigrationsFrom(0);
      expect(freshMigrations.length, 3);
      expect(freshMigrations[0].version, 1);
      expect(freshMigrations[1].version, 2);
      expect(freshMigrations[2].version, 3);

      // From version 1 (existing v1 database)
      final v1Migrations = MigrationRegistry.getMigrationsFrom(1);
      expect(v1Migrations.length, 2);
      expect(v1Migrations[0].version, 2);
      expect(v1Migrations[1].version, 3);

      // From version 2
      final v2Migrations = MigrationRegistry.getMigrationsFrom(2);
      expect(v2Migrations.length, 1);
      expect(v2Migrations[0].version, 3);

      // From version 3 (current version)
      final v3Migrations = MigrationRegistry.getMigrationsFrom(3);
      expect(v3Migrations.length, 0);
    });

    test('MigrationRegistry latest version is correct', () {
      expect(MigrationRegistry.getLatestVersion(), 3);
    });

    test('Migration tracking records applied_at timestamp', () async {
      await testDb.execute('''
        CREATE TABLE schema_migrations (
          version INTEGER PRIMARY KEY,
          description TEXT NOT NULL,
          applied_at INTEGER NOT NULL,
          checksum TEXT
        )
      ''');

      final beforeTime = DateTime.now().millisecondsSinceEpoch;

      await testDb.insert('schema_migrations', {
        'version': 1,
        'description': 'Test migration',
        'applied_at': DateTime.now().millisecondsSinceEpoch,
      });

      final afterTime = DateTime.now().millisecondsSinceEpoch;

      final result = await testDb.query('schema_migrations');
      final appliedAt = result[0]['applied_at'] as int;

      expect(appliedAt, greaterThanOrEqualTo(beforeTime));
      expect(appliedAt, lessThanOrEqualTo(afterTime));
    });

    test('Migration runs in transaction and rolls back on error', () async {
      await testDb.execute('''
        CREATE TABLE fuel_entries (
          id TEXT PRIMARY KEY,
          date INTEGER NOT NULL,
          liters REAL NOT NULL,
          kilometers REAL NOT NULL,
          total_cost REAL NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Verify table exists before
      final beforeTables = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='fuel_entries'"
      );
      expect(beforeTables.length, 1);

      // Attempt a migration that will fail
      try {
        await testDb.transaction((txn) async {
          // This should work
          await txn.execute('DROP TABLE fuel_entries');

          // This should fail (invalid SQL)
          await txn.execute('INVALID SQL STATEMENT');
        });
        fail('Expected transaction to fail');
      } catch (e) {
        // Transaction should roll back
      }

      // Verify table still exists (rollback worked)
      final afterTables = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='fuel_entries'"
      );
      expect(afterTables.length, 1);
    });
  });
}
