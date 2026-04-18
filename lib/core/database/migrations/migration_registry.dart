// ABOUTME: Central registry for all database migrations in version order
// ABOUTME: Provides methods to retrieve pending migrations based on current database version

import 'migration.dart';
import 'v1_initial_schema.dart';
import 'v2_add_migration_tracking.dart';
import 'v3_add_soft_delete.dart';

class MigrationRegistry {
  /// All registered migrations in ascending version order
  static final List<Migration> _migrations = [
    V1InitialSchema(),
    V2AddMigrationTracking(),
    V3AddSoftDelete(),
  ];

  /// Get all migrations that need to be applied from a given version
  ///
  /// [currentVersion] The current database version
  /// Returns list of migrations to apply, in order
  static List<Migration> getMigrationsFrom(int currentVersion) {
    return _migrations
        .where((migration) => migration.version > currentVersion)
        .toList()
      ..sort((a, b) => a.version.compareTo(b.version));
  }

  /// Get all registered migrations
  static List<Migration> getAllMigrations() {
    return List.unmodifiable(_migrations);
  }

  /// Get the latest migration version
  static int getLatestVersion() {
    if (_migrations.isEmpty) return 0;
    return _migrations.map((m) => m.version).reduce((a, b) => a > b ? a : b);
  }
}
