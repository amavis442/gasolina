// ABOUTME: Migration to add schema_migrations table for tracking database version history
// ABOUTME: Enables robust migration management and prevents re-running applied migrations

import 'package:sqflite/sqflite.dart';
import 'migration.dart';

class V2AddMigrationTracking implements Migration {
  @override
  int get version => 2;

  @override
  String get description => 'Add schema_migrations table for version tracking';

  @override
  Future<void> up(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE schema_migrations (
        version INTEGER PRIMARY KEY,
        description TEXT NOT NULL,
        applied_at INTEGER NOT NULL,
        checksum TEXT
      )
    ''');
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await db.execute('DROP TABLE IF EXISTS schema_migrations');
  }
}
