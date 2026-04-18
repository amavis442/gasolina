// ABOUTME: Migration representing the initial v1 database schema
// ABOUTME: Used for backfilling migration tracking on existing v1 databases

import 'package:sqflite/sqflite.dart';
import 'migration.dart';

class V1InitialSchema implements Migration {
  @override
  int get version => 1;

  @override
  String get description => 'Initial schema with fuel_entries table';

  @override
  Future<void> up(DatabaseExecutor db) async {
    // This migration represents the existing v1 schema
    // For fresh installations, create the fuel_entries table
    // For existing v1 databases, these tables already exist, so we check first

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='fuel_entries'"
    );

    if (tables.isEmpty) {
      // Fresh installation - create the tables
      await db.execute('''
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

      await db.execute('''
        CREATE INDEX idx_fuel_entries_date ON fuel_entries(date DESC)
      ''');
    }
    // If tables already exist (v1 database upgrade), do nothing
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await db.execute('DROP INDEX IF EXISTS idx_fuel_entries_date');
    await db.execute('DROP TABLE IF EXISTS fuel_entries');
  }
}
