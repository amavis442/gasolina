// ABOUTME: SQLite database service implementation using sqflite package
// ABOUTME: Manages database initialization, schema creation, version management, and migrations

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'migrations/migration_registry.dart';

class SqfliteDatabaseService implements DatabaseService {
  static const String _databaseName = 'gasolina.db';
  static const int _databaseVersion = 3;

  Database? _database;

  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    await initialize();
    return _database!;
  }

  @override
  Future<void> initialize() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // For fresh installations, run all migrations up to the target version
    await _runMigrations(db, 0, version);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Run migrations from old version to new version
    await _runMigrations(db, oldVersion, newVersion);
  }

  Future<void> _runMigrations(Database db, int fromVersion, int toVersion) async {
    try {
      // Detect actual current version (handles v1 databases without schema_migrations table)
      final currentVersion = await _getCurrentVersion(db);

      // Get all pending migrations
      final migrations = MigrationRegistry.getMigrationsFrom(currentVersion);

      if (migrations.isEmpty) {
        return;
      }

      // Execute each migration in a transaction
      for (final migration in migrations) {
        if (migration.version > toVersion) {
          break; // Don't run migrations beyond target version
        }

        await db.transaction((txn) async {
          await migration.up(txn);

          // Record migration in schema_migrations table (if it exists)
          // For v1->v2 migration, the table is created by V2AddMigrationTracking
          final tables = await txn.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='schema_migrations'"
          );

          if (tables.isNotEmpty) {
            await txn.insert('schema_migrations', {
              'version': migration.version,
              'description': migration.description,
              'applied_at': DateTime.now().millisecondsSinceEpoch,
            });
          }
        });
      }
    } catch (e) {
      // Transaction automatically rolls back on error
      rethrow;
    }
  }

  /// Detect the current database version
  ///
  /// Returns 0 for fresh database, 1 for v1 database without migration tracking,
  /// or the latest version from schema_migrations table
  Future<int> _getCurrentVersion(Database db) async {
    try {
      // Check if schema_migrations table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='schema_migrations'"
      );

      if (tables.isEmpty) {
        // Check if fuel_entries table exists (indicates v1 database)
        final fuelTables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='fuel_entries'"
        );

        return fuelTables.isEmpty ? 0 : 1;
      }

      // Get latest version from schema_migrations
      final result = await db.rawQuery(
        'SELECT MAX(version) as version FROM schema_migrations'
      );

      return result.first['version'] as int? ?? 0;
    } catch (e) {
      // If any error occurs, assume fresh database
      return 0;
    }
  }

  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
